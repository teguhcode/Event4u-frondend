import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import '../../../routes/app_router.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/main_scaffold.dart';
import 'midtrans_webview_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final PaymentArgs args;
  const PaymentScreen({super.key, required this.args});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late Timer _timer;
  int _secs = 24 * 60 * 60;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secs > 0) setState(() => _secs--);
      else _timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
  String get _h => _pad(_secs ~/ 3600);
  String get _m => _pad((_secs % 3600) ~/ 60);
  String get _s => _pad(_secs % 60);

  String _rp(int v) {
    final s = v.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp$s';
  }

  /// Buka Midtrans Snap di WebView — setara startPaymentUiFlow() native SDK.
  /// Hasilnya berupa MidtransResult, setara TransactionResult Android.
  Future<void> _openMidtransSnap() async {
    final url = widget.args.redirectUrl;
    if (url == null || url.isEmpty) {
      _showSnack('URL pembayaran tidak tersedia', AppColors.errorRed);
      return;
    }

    final result = await Navigator.of(context).push<MidtransResult>(
      MaterialPageRoute(
        builder: (_) => MidtransWebViewScreen(
          redirectUrl: url,
          orderId: widget.args.orderId,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result == null || !mounted) return;
    _handleMidtransResult(result);
  }

  /// Sesuai pola onActivityResult() di tutorial native:
  /// STATUS_SUCCESS / STATUS_PENDING / STATUS_FAILED / STATUS_CANCELED / STATUS_INVALID
  void _handleMidtransResult(MidtransResult result) {
    switch (result.status) {
      case MidtransTxStatus.success:
        _showSnack(
          'Transaksi Selesai. ID: ${result.transactionId ?? "-"}',
          AppColors.successGreen,
        );
        _confirmPaymentToBackend();
        break;

      case MidtransTxStatus.pending:
        _showSnack(
          'Transaksi Pending. ID: ${result.transactionId ?? "-"}',
          AppColors.festivalOrange,
        );
        // Tetap cek ke backend — siapa tahu sudah settlement saat kita poll
        _confirmPaymentToBackend(silent: true);
        break;

      case MidtransTxStatus.failed:
        _showSnack(
          'Transaksi Gagal. ID: ${result.transactionId ?? "-"}',
          AppColors.errorRed,
        );
        break;

      case MidtransTxStatus.cancelled:
        _showSnack('Transaksi Dibatalkan', AppColors.textSecondary);
        break;

      case MidtransTxStatus.invalid:
        _showSnack('Transaksi Tidak Valid', AppColors.errorRed);
        break;
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  /// Konfirmasi status final ke backend Laravel via /pay
  /// (backend akan cek ulang ke Midtrans::Transaction::status())
  Future<void> _confirmPaymentToBackend({bool silent = false}) async {
    if (widget.args.transactionId == null) return;
    if (!silent) setState(() => _checking = true);

    final tx = await ref
        .read(checkoutProvider.notifier)
        .pay(widget.args.transactionId!, 'midtrans');

    if (!silent) setState(() => _checking = false);
    if (!mounted || tx == null) return;

    if (tx.status == TransactionStatus.paid) {
      context.push(AppRoutes.paymentSuccess, extra: tx);
    } else if (!silent) {
      _showSnack(
        'Status saat ini: ${tx.statusLabel}',
        AppColors.festivalOrange,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final hasRedirectUrl =
        widget.args.redirectUrl != null && widget.args.redirectUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
        child: Column(children: [
          _CountdownCard(
            h: _h, m: _m, s: _s,
            total: _rp(widget.args.totalAmount),
            orderId: widget.args.orderId,
          ),
          const SizedBox(height: 12),

          // ── Midtrans Card ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0066FF),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text('midtrans',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: 0.5)),
                ),
                const SizedBox(width: 8),
                Text('Snap Payment',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 16),

              Text('Metode pembayaran tersedia:',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _PayBadge('QRIS', Icons.qr_code_2_rounded,
                      const Color(0xFF0066FF)),
                  _PayBadge('GoPay', Icons.wallet_rounded,
                      const Color(0xFF00AED6)),
                  _PayBadge('Virtual Account', Icons.account_balance_rounded,
                      const Color(0xFF1E2A78)),
                  _PayBadge('Kartu Kredit', Icons.credit_card_rounded,
                      const Color(0xFF16A34A)),
                ],
              ),
              const SizedBox(height: 20),

              if (hasRedirectUrl)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openMidtransSnap,
                    icon: const Icon(Icons.payment_rounded,
                        color: Colors.white, size: 18),
                    label: Text('Bayar Sekarang',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    'URL pembayaran tidak tersedia.\nPastikan Midtrans key sudah benar.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.errorRed),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 12),

          if (checkoutState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(checkoutState.error!,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.errorRed)),
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _checking ? null : () => _confirmPaymentToBackend(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: AppColors.electricBlue, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _checking
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.electricBlue, strokeWidth: 2.5))
                  : Text('Cek Status Pembayaran',
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.electricBlue)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────
class _CountdownCard extends StatelessWidget {
  final String h, m, s, total, orderId;
  const _CountdownCard({
    required this.h, required this.m, required this.s,
    required this.total, required this.orderId,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.deepIndigo, Color(0xFF2F3FA8)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(children: [
          Text('Selesaikan pembayaran dalam',
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _TUnit(value: h, label: 'Jam'),
            _Sep(),
            _TUnit(value: m, label: 'Menit'),
            _Sep(),
            _TUnit(value: s, label: 'Detik'),
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total Pembayaran',
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.white.withOpacity(0.75))),
            Text(total,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Order ID',
                style: GoogleFonts.inter(
                    fontSize: 11, color: Colors.white.withOpacity(0.55))),
            Text(orderId,
                style: GoogleFonts.robotoMono(
                    fontSize: 11, color: Colors.white.withOpacity(0.75))),
          ]),
        ]),
      );
}

class _TUnit extends StatelessWidget {
  final String value, label;
  const _TUnit({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8)),
          child: Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 26, fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10, color: Colors.white.withOpacity(0.6))),
      ]);
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
        child: Text(':',
            style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.w700,
                color: Colors.white)),
      );
}

class _PayBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _PayBadge(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
      );
}
