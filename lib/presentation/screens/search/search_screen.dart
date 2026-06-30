import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_router.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card_vertical.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    setState(() => _query = q);
    ref.read(eventListProvider.notifier).fetchEvents(search: q);
  }

  void _clearSearch() {
    _ctrl.clear();
    _onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(eventListProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: TextField(
          controller: _ctrl,
          autofocus: false,
          onChanged: _onSearch,
          style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Cari event...',
            hintStyle: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.search_rounded,
                size: 20, color: AppColors.textSecondary),
            suffixIcon: _query.isNotEmpty
                ? GestureDetector(
                    onTap: _clearSearch,
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: AppColors.textSecondary),
                  )
                : null,
            filled: true,
            fillColor: AppColors.pageBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.electricBlue, width: 1.5)),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: Builder(builder: (_) {
        if (eventState.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.electricBlue));
        }
        if (eventState.error != null) {
          return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Text('😵', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 10),
              Text(eventState.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _onSearch(_query),
                child: const Text('Coba Lagi'),
              ),
            ]),
          );
        }
        if (eventState.events.isEmpty) {
          return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Text('🔍', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              Text(
                _query.isEmpty
                    ? 'Belum ada event tersedia'
                    : 'Event "$_query" tidak ditemukan',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              if (_query.isNotEmpty)
                Text('Coba kata kunci lain',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary)),
            ]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: eventState.events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final e = eventState.events[i];
            return EventCardVertical(
              eventId:  e.id,
              name:     e.title,
              date:     e.formattedDate,
              time:     e.formattedTime,
              price:    e.formattedPrice,
              emoji:    '🎟️',
              imageUrl: e.fullImageUrl(ApiConstants.baseUrl),
              bgColor: _bgColor(i),
              onTap: () => context.push(AppRoutes.eventDetailPath(e.id)),
            );
          },
        );
      }),
    );
  }

  static Color _bgColor(int i) {
    const colors = [
      Color(0xFFEFF4FF), Color(0xFFFFF0EB), Color(0xFFECFDF5),
      Color(0xFFFDF0FF), Color(0xFFFFF7ED),
    ];
    return colors[i % colors.length];
  }
}
