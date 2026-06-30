import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import '../../../routes/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/main_scaffold.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final TransactionModel transaction;
  const PaymentSuccessScreen({super.key, required this.transaction});

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim =
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _rp(double v) {
    final s = v.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp$s';
  }

  @override
  Widget build(BuildContext context) {
    final tx   = widget.transaction;
    final user = ref.read(authProvider).user;

    // Build e-ticket dari transaction (support multi-tiket)
    // ETicketScreen akan generate semua tiket dari totalTickets via PageView
    final txIdStr = tx.id.toString().padLeft(6, '0');
    final eTicket = ETicketModel(
      bookingId:      'TKT-$txIdStr-1',
      transactionId:  'TKT-$txIdStr',
      holderName:     user?.name ?? '-',
      eventName:      tx.event?.title ?? '-',
      eventDate:      tx.event?.eventDate ?? '-',
      eventTime:      '-',
      venue:          tx.event?.location ?? '-',
      ticketCategory: 'Festival A',
      ticketNumber:   1,
      totalTickets:   tx.quantity,  // ETicketScreen generate semua dari sini
    );

    return Scaffold(
      backgroundColor: AppColors.deepIndigo,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 32),
            // Confetti dots
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _Dot(color: const Color(0xFF7FC8F8)),
              const SizedBox(width: 8),
              _Dot(color: AppColors.festivalOrange),
              const SizedBox(width: 8),
              _Dot(color: AppColors.neonPink),
              const SizedBox(width: 8),
              _Dot(color: AppColors.successGreen),
            ]),
            const SizedBox(height: 28),
            // Green checkmark — UX: green = success signal
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: AppColors.successGreen.withOpacity(0.45),
                    blurRadius: 24, offset: const Offset(0, 8),
                  )],
                ),
                child: const Icon(Icons.check_rounded,
                    size: 46, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(children: [
                Text('Pembayaran Berhasil!',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  'Terima kasih, pembayaran kamu telah\nberhasil diproses.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.65),
                      height: 1.6),
                ),
                const SizedBox(height: 24),

                // Transaction card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.18), width: 0.5),
                  ),
                  child: Column(children: [
                    _TxRow(
                        label: 'Event',
                        value: tx.event?.title ?? 'Event #${tx.eventId}'),
                    _TxRow(label: 'Metode', value: tx.paymentMethod),
                    _TxRow(
                        label: 'Order ID',
                        value: 'TKT-${tx.id.toString().padLeft(6, '0')}',
                        mono: true),
                    _TxRow(
                        label: 'Total Bayar',
                        value: _rp(tx.total),
                        highlight: true,
                        last: true),
                  ]),
                ),
                const SizedBox(height: 24),

                // Primary CTA — white on dark = max contrast
                GestureDetector(
                  onTap: () => context.push(
                      AppRoutes.eticket, extra: eTicket),
                  child: Container(
                    width: double.infinity, height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16, offset: const Offset(0, 6),
                      )],
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const Icon(Icons.confirmation_num_outlined,
                          color: AppColors.deepIndigo, size: 20),
                      const SizedBox(width: 8),
                      Text('Lihat Tiket Saya',
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: AppColors.deepIndigo)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary CTA
                GestureDetector(
                  onTap: () => context.go(AppRoutes.home),
                  child: Container(
                    width: double.infinity, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1.5),
                    ),
                    child: Center(
                      child: Text('Kembali ke Beranda',
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.85))),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final String label, value;
  final bool highlight, mono, last;
  const _TxRow({required this.label, required this.value,
      this.highlight = false, this.mono = false, this.last = false});

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6))),
            const Spacer(),
            Text(value,
                style: mono
                    ? GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500)
                    : GoogleFonts.inter(
                        fontSize: highlight ? 15 : 12,
                        fontWeight: highlight
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: highlight
                            ? const Color(0xFF7FC8F8)
                            : Colors.white)),
          ]),
        ),
        if (!last)
          Divider(height: 1, thickness: 0.5,
              color: Colors.white.withOpacity(0.12)),
      ]);
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
