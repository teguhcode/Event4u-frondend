import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../routes/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/main_scaffold.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  int _qty = 1;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    // Refresh event detail setiap kali layar dibuka ulang (quota update)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(eventDetailProvider(widget.eventId));
    });
  }

  String _rp(double amount) {
    if (amount == 0) return 'Gratis';
    final s = amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp$s';
  }

  @override
  Widget build(BuildContext context) {
    final asyncEvent = ref.watch(eventDetailProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: asyncEvent.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.electricBlue)),
        error: (e, _) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('😵', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            Text('Gagal memuat event',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(e.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(
                  eventDetailProvider(widget.eventId)),
              child: const Text('Coba Lagi'),
            ),
          ]),
        ),
        data: (event) => _buildContent(context, event),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EventModel event) {
    final total = event.ticketPrice * _qty;

    return Stack(children: [
      CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _buildHero(context, event)),
        SliverToBoxAdapter(child: _buildBody(event)),
        const SliverPadding(padding: EdgeInsets.only(bottom: 90)),
      ]),
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: _buildStickyBar(context, event, total),
      ),
    ]);
  }

  Widget _buildHero(BuildContext context, EventModel event) {
    final imgUrl = event.fullImageUrl(ApiConstants.baseUrl);

    return SizedBox(
      height: 260,
      child: Stack(fit: StackFit.expand, children: [
        imgUrl != null
            ? CachedNetworkImage(
                imageUrl: imgUrl,
                httpHeaders: const {
                  'ngrok-skip-browser-warning': 'true',
                  'Accept': 'image/*',
                },
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _heroFallback())
            : _heroFallback(),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xCC1E2A78)],
              stops: [0.4, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HeroBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.pop()),
                _HeroBtn(
                  icon: _isFavorited
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor:
                      _isFavorited ? AppColors.errorRed : Colors.white,
                  onTap: () =>
                      setState(() => _isFavorited = !_isFavorited),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _heroFallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.deepIndigo, Color(0xFF2F6BFF)],
          ),
        ),
        child: const Center(
            child: Text('🎟️', style: TextStyle(fontSize: 72))),
      );

  Widget _buildBody(EventModel event) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.electricBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('EVENT',
              style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppColors.electricBlue, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 8),
        Text(event.title,
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, height: 1.3)),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(child: _MetaCard(icon: '📅', label: 'Tanggal',
              value: event.formattedDate)),
          const SizedBox(width: 10),
          Expanded(child: _MetaCard(icon: '🕖', label: 'Waktu',
              value: event.formattedTime)),
        ]),
        const SizedBox(height: 8),
        _MetaCard(icon: '📍', label: 'Lokasi', value: event.location,
            fullWidth: true),
        const SizedBox(height: 8),
        // Kuota — live dari API
        _MetaCard(
            icon: '🎫',
            label: 'Kuota',
            value: event.quota > 0
                ? '${event.quota} tiket tersedia'
                : '⚠ Tiket habis',
            fullWidth: true,
            valueColor: event.quota > 0
                ? AppColors.textPrimary
                : AppColors.errorRed),

        const SizedBox(height: 20),
        Text('Tentang Event',
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(event.description,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary,
                height: 1.7)),

        const SizedBox(height: 20),
        Text('Pilih Tiket',
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),

        _TicketCard(
          name:           'Festival A',
          price:          event.ticketPrice,
          availableStock: event.quota,
          quantity:       _qty,
          onDecrement: _qty > 1 ? () => setState(() => _qty--) : null,
          onIncrement: (_qty < 6 && event.quota > 0)
              ? () => setState(() => _qty++)
              : null,
        ),
      ]),
    );
  }

  Widget _buildStickyBar(
      BuildContext context, EventModel event, double total) {
    final auth = ref.read(authProvider);
    final soldOut = event.quota <= 0;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border:
            Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
          Text('Total Harga',
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary)),
          Text(soldOut ? 'Habis' : _rp(total),
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: soldOut
                      ? AppColors.errorRed
                      : AppColors.textPrimary)),
        ]),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            label: soldOut ? 'Tiket Habis' : 'Pesan Sekarang',
            backgroundColor: soldOut
                ? AppColors.textSecondary
                : AppColors.electricBlue,
            onTap: soldOut
                ? null
                : () {
                    if (!auth.isLoggedIn) {
                      context.push(
                          '${AppRoutes.login}?redirect=/event/${event.id}');
                      return;
                    }
                    context.push(
                      AppRoutes.checkout,
                      extra: CheckoutArgs(
                        eventId:        event.id,
                        eventName:      event.title,
                        eventDate:      event.formattedDate,
                        eventTime:      event.formattedTime,
                        ticketTypeId:   1,
                        ticketTypeName: 'Festival A',
                        ticketPrice:    event.ticketPrice.toInt(),
                        quantity:       _qty,
                      ),
                    );
                  },
          ),
        ),
      ]),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────
class _HeroBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  const _HeroBtn({required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18)),
          child: Icon(icon, size: 18, color: iconColor ?? Colors.white),
        ),
      );
}

class _MetaCard extends StatelessWidget {
  final String icon, label, value;
  final bool fullWidth;
  final Color? valueColor;
  const _MetaCard({required this.icon, required this.label,
      required this.value, this.fullWidth = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(
              fontSize: 10, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary)),
        ])),
      ]),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: card) : card;
  }
}

class _TicketCard extends StatelessWidget {
  final String name;
  final double price;
  final int availableStock, quantity;
  final VoidCallback? onDecrement, onIncrement;

  const _TicketCard({
    required this.name, required this.price,
    required this.availableStock, required this.quantity,
    this.onDecrement, this.onIncrement,
  });

  String _rp(double v) {
    final s = v.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
          Text(_rp(price), style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: AppColors.electricBlue)),
          Text(
            availableStock > 0
                ? 'Tersedia $availableStock tiket'
                : '⚠ Stok habis',
            style: GoogleFonts.inter(
                fontSize: 11,
                color: availableStock > 0
                    ? AppColors.textSecondary
                    : AppColors.errorRed),
          ),
        ])),
        Row(children: [
          _StepBtn(icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: 32,
            child: Center(
              child: Text('$quantity', style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onIncrement),
        ]),
      ]),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: active ? AppColors.electricBlue : AppColors.border,
              width: 1.5),
        ),
        child: Icon(icon, size: 16,
            color: active ? AppColors.electricBlue : AppColors.border),
      ),
    );
  }
}
