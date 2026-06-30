import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import '../../../routes/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Tiket Saya',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: auth.isLoggedIn
          ? _LoggedInTickets()
          : _GuestTickets(),
    );
  }
}

// ── Guest ─────────────────────────────────────────────────────────────────────
class _GuestTickets extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🎟️', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('Belum ada tiket',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('Masuk untuk melihat tiket dan\nriwayat transaksi kamu.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.push(AppRoutes.login),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.35),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Center(child: Text('Masuk / Daftar',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: Colors.white))),
              ),
            ),
          ]),
        ),
      );
}

// ── Logged In — GET /api/transactions ─────────────────────────────────────────
class _LoggedInTickets extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LoggedInTickets> createState() => _LoggedInTicketsState();
}

class _LoggedInTicketsState extends ConsumerState<_LoggedInTickets> {
  @override
  void initState() {
    super.initState();
    // Invalidate cache setiap kali layar Tiket dibuka → data selalu fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(transactionHistoryProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(transactionHistoryProvider);

    return DefaultTabController(
      length: 3,
      child: Column(children: [
        Container(
          color: AppColors.cardBg,
          child: TabBar(
            labelStyle: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w400),
            labelColor: AppColors.electricBlue,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.electricBlue,
            indicatorWeight: 2.5,
            tabs: const [
              Tab(text: 'Aktif'),
              Tab(text: 'Menunggu'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.electricBlue)),
            error: (e, _) => Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const Text('😵', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 10),
                Text('Gagal memuat tiket',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(e.toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(transactionHistoryProvider),
                  child: const Text('Coba Lagi'),
                ),
              ]),
            ),
            data: (txList) {
              final paid      = txList.where(
                  (t) => t.status == TransactionStatus.paid).toList();
              final pending   = txList.where(
                  (t) => t.status == TransactionStatus.pending).toList();
              final cancelled = txList.where(
                  (t) => t.status == TransactionStatus.cancelled).toList();

              return TabBarView(children: [
                _TxList(items: paid,      emptyMsg: 'Belum ada tiket aktif'),
                _TxList(items: pending,   emptyMsg: 'Tidak ada yang menunggu'),
                _TxList(items: cancelled, emptyMsg: 'Belum ada tiket selesai'),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

class _TxList extends ConsumerWidget {
  final List<TransactionModel> items;
  final String emptyMsg;
  const _TxList({required this.items, required this.emptyMsg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🎟️', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 10),
        Text(emptyMsg,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary)),
      ]));
    }

    return RefreshIndicator(
      color: AppColors.electricBlue,
      onRefresh: () async => ref.refresh(transactionHistoryProvider),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _TxCard(tx: items[i]),
      ),
    );
  }
}

class _TxCard extends StatelessWidget {
  final TransactionModel tx;
  const _TxCard({required this.tx});

  String _rp(double v) {
    final s = v.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp$s';
  }

  Color get _statusColor {
    switch (tx.status) {
      case TransactionStatus.paid:      return AppColors.successGreen;
      case TransactionStatus.pending:   return AppColors.festivalOrange;
      case TransactionStatus.cancelled: return AppColors.errorRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tx.status == TransactionStatus.paid
          ? () {
              final txIdStr = tx.id.toString().padLeft(6, '0');
              final eTicket = ETicketModel(
                bookingId:      'TKT-$txIdStr-1',
                transactionId:  'TKT-$txIdStr',
                holderName:     '-',
                eventName:      tx.event?.title ?? '-',
                eventDate:      tx.event?.eventDate ?? '-',
                eventTime:      '-',
                venue:          tx.event?.location ?? '-',
                ticketCategory: 'Festival A',
                ticketNumber:   1,
                totalTickets:   tx.quantity,
              );
              context.push(AppRoutes.eticket, extra: eTicket);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(
                tx.event?.title ?? 'Event #${tx.eventId}',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(tx.statusLabel,
                  style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: _statusColor)),
            ),
          ]),
          const SizedBox(height: 6),
          if (tx.event != null)
            Row(children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Text(tx.event!.location,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary)),
            ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.confirmation_num_outlined,
                size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 3),
            Text('${tx.quantity} Tiket · ${tx.paymentMethod}',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
          const SizedBox(height: 8),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Text('Total: ${_rp(tx.total)}',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppColors.electricBlue)),
            if (tx.status == TransactionStatus.paid)
              Text('Tap untuk lihat tiket →',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ]),
      ),
    );
  }
}
