import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import '../../widgets/main_scaffold.dart';

class ETicketScreen extends StatefulWidget {
  final ETicketModel eTicket;
  const ETicketScreen({super.key, required this.eTicket});

  @override
  State<ETicketScreen> createState() => _ETicketScreenState();
}

class _ETicketScreenState extends State<ETicketScreen> {
  late final List<ETicketModel> _tickets;
  late final PageController _pageCtrl;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Buat list semua tiket berdasarkan totalTickets
    final base = widget.eTicket;
    _tickets = List.generate(base.totalTickets, (i) {
      final no = i + 1;
      final txId = base.transactionId;
      return ETicketModel(
        bookingId:      '$txId-$no',
        transactionId:  txId,
        holderName:     base.holderName,
        eventName:      base.eventName,
        eventDate:      base.eventDate,
        eventTime:      base.eventTime,
        venue:          base.venue,
        ticketCategory: base.ticketCategory,
        ticketNumber:   no,
        totalTickets:   base.totalTickets,
      );
    });
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Agt','Sep','Okt','Nov','Des'
      ];
      final time =
          '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')} WIB';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year} · $time';
    } catch (_) {
      return raw;
    }
  }

  void _copyId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('ID Tiket disalin: $id',
          style: GoogleFonts.inter(fontSize: 13)),
      backgroundColor: AppColors.successGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = _tickets.length > 1;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      appBar: AppBar(
        title: Text(
          hasMultiple
              ? 'E-Ticket (${_currentPage + 1}/${_tickets.length})'
              : 'E-Ticket',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(children: [
        // ── Counter dots jika multi-tiket ──────────────────────────────
        if (hasMultiple) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_tickets.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? AppColors.electricBlue
                    : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          ),
          const SizedBox(height: 4),
          Text(
            'Geser untuk lihat tiket lainnya',
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
        ],

        // ── PageView tiket ──────────────────────────────────────────────
        Expanded(
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: _tickets.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildTicketCard(_tickets[i]),
                const SizedBox(height: 16),
                _buildVerificationCard(_tickets[i]),
                const SizedBox(height: 12),
                _buildHint(hasMultiple),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildTicketCard(ETicketModel ticket) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20, offset: const Offset(0, 4),
        )],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: [
          _buildHeader(ticket),
          _buildDivider(),
          _buildBody(ticket),
        ]),
      ),
    );
  }

  Widget _buildHeader(ETicketModel ticket) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.deepIndigo, Color(0xFF2F3FA8)],
          ),
        ),
        child: Stack(children: [
          Column(children: [
            const Text('🎟️', style: TextStyle(fontSize: 34)),
            const SizedBox(height: 8),
            Text(ticket.eventName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              '${_formatDate(ticket.eventDate)}\n${ticket.venue}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 11, color: Colors.white.withOpacity(0.65)),
            ),
          ]),
          // Badge kategori + nomor tiket
          Positioned(
            top: 0, right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(ticket.ticketCategory,
                      style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                if (ticket.totalTickets > 1) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.festivalOrange.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Tiket ${ticket.ticketNumber}/${ticket.totalTickets}',
                      style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ]),
      );

  Widget _buildDivider() => Row(children: [
        _Notch(),
        Expanded(child: LayoutBuilder(builder: (_, c) => Row(
          children: List.generate(
            (c.maxWidth / 10).floor(),
            (i) => Expanded(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 1.5,
              color: i.isEven ? AppColors.border : Colors.transparent,
            )),
          ),
        ))),
        _Notch(),
      ]);

  Widget _buildBody(ETicketModel ticket) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _InfoItem(label: 'Nama Pemesan', value: ticket.holderName),
            _InfoItem(label: 'Kategori',     value: ticket.ticketCategory),
            _InfoItem(label: 'No. Tiket',
                value: '${ticket.ticketNumber} dari ${ticket.totalTickets}'),
            _InfoItem(label: 'Lokasi',       value: ticket.venue),
          ],
        ),
      );

  Widget _buildVerificationCard(ETicketModel ticket) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12, offset: const Offset(0, 2),
        )],
      ),
      child: Column(children: [
        // Header
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: AppColors.electricBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.verified_outlined,
                color: AppColors.electricBlue, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ID Verifikasi Tiket',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text('Tunjukkan ke petugas untuk masuk',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ]),
        const SizedBox(height: 16),

        // Booking ID — unik per tiket
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.electricBlue.withOpacity(0.3), width: 1.5),
          ),
          child: Column(children: [
            Text('BOOKING ID',
                style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(
              ticket.bookingId,
              style: GoogleFonts.robotoMono(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.electricBlue, letterSpacing: 2),
            ),
            if (ticket.totalTickets > 1) ...[
              const SizedBox(height: 4),
              Text(
                'Tiket ${ticket.ticketNumber} dari ${ticket.totalTickets}',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 12),

        // Salin button
        GestureDetector(
          onTap: () => _copyId(ticket.bookingId),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.electricBlue,
                borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text('Salin ID Tiket Ini',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ]),
          ),
        ),
        const SizedBox(height: 10),

        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.successGreen, size: 14),
            const SizedBox(width: 5),
            Text('Pembayaran Terverifikasi',
                style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppColors.successGreen)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildHint(bool isMultiple) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.electricBlue.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.electricBlue.withOpacity(0.2), width: 0.5),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.electricBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isMultiple
                  ? 'Setiap tiket memiliki ID unik. Tunjukkan masing-masing ID ke petugas saat masuk venue.'
                  : 'Tunjukkan Booking ID ini ke petugas saat masuk venue.',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.electricBlue, height: 1.5),
            ),
          ),
        ]),
      );
}

class _Notch extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
            color: AppColors.pageBg, shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 0.5)));
}

class _InfoItem extends StatelessWidget {
  final String label, value;
  const _InfoItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 9, color: AppColors.textSecondary,
                  letterSpacing: 0.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ]);
}
