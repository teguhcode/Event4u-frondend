import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card_horizontal.dart';
import '../../widgets/event_card_vertical.dart';
import '../../widgets/search_bar_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Refresh event list setiap kali app kembali ke foreground / user balik ke home
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(eventListProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth       = ref.watch(authProvider);
    final eventState = ref.watch(eventListProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: RefreshIndicator(
        color: AppColors.electricBlue,
        onRefresh: () => ref.read(eventListProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(auth: auth)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.search),
                  child: const SearchBarWidget(),
                ),
              ),
            ),

            // ── Body berdasarkan state API ──────────────────────────────
            if (eventState.isLoading)
              const SliverFillRemaining(child: _LoadingBody())
            else if (eventState.error != null)
              SliverFillRemaining(
                child: _ErrorBody(
                  message: eventState.error!,
                  onRetry: () =>
                      ref.read(eventListProvider.notifier).refresh(),
                ),
              )
            else if (eventState.events.isEmpty)
              const SliverFillRemaining(child: _EmptyBody())
            else ...[
              // Popular (3 teratas)
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Event Terpopuler',
                  onSeeAll: () => context.go(AppRoutes.search),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: eventState.events.take(3).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final e = eventState.events[i];
                      return EventCardHorizontal(
                        eventId:  e.id,
                        name:     e.title,
                        date:     '${e.formattedDate} · ${e.formattedTime}',
                        price:    e.formattedPrice,
                        emoji:    '🎟️',
                        imageUrl: e.fullImageUrl(ApiConstants.baseUrl),
                        bgColor:  _bgColor(i),
                        onTap: () => context.push(
                            AppRoutes.eventDetailPath(e.id)),
                      );
                    },
                  ),
                ),
              ),

              // All Events
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Semua Event',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final e = eventState.events[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: EventCardVertical(
                        eventId:  e.id,
                        name:     e.title,
                        date:     e.formattedDate,
                        time:     e.formattedTime,
                        price:    e.formattedPrice,
                        emoji:    '🎟️',
                        imageUrl: e.fullImageUrl(ApiConstants.baseUrl),
                        bgColor: _bgColor(i),
                        onTap: () => context.push(
                            AppRoutes.eventDetailPath(e.id)),
                      ),
                    );
                  },
                  childCount: eventState.events.length,
                ),
              ),
              const SliverPadding(
                  padding: EdgeInsets.only(bottom: 16)),
            ],
          ],
        ),
      ),
    );
  }

  static Color _bgColor(int i) {
    const colors = [
      Color(0xFFEFF4FF), Color(0xFFFFF0EB), Color(0xFFECFDF5),
      Color(0xFFFDF0FF), Color(0xFFFFF7ED), Color(0xFFEFF4FF),
    ];
    return colors[i % colors.length];
  }
}

// ── Header ─────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final AuthState auth;
  const _Header({required this.auth});

  @override
  Widget build(BuildContext context) {
    final name = auth.user?.firstName ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                auth.isLoggedIn ? 'Halo, $name 👋' : 'Halo, Selamat Datang 👋',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                auth.isLoggedIn
                    ? 'Mau nonton event apa hari ini?'
                    : 'Temukan event terbaik hari ini',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          if (!auth.isLoggedIn)
            GestureDetector(
              onTap: () => context.push(AppRoutes.login),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.electricBlue,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Masuk',
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            )
          else
            GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                    color: AppColors.electricBlue,
                    shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    auth.user?.initial ?? 'U',
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text('Lihat Semua',
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.electricBlue)),
          ),
      ]),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();
  @override
  Widget build(BuildContext context) => const Center(
      child: CircularProgressIndicator(color: AppColors.electricBlue));
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('😵', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('Gagal memuat event',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ]),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🎟️', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text('Belum ada event tersedia',
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ]),
    );
  }
}
