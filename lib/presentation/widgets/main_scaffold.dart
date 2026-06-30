import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _locationToIndex(String loc) {
    if (loc.startsWith(AppRoutes.search))    return 1;
    if (loc.startsWith(AppRoutes.myTickets)) return 2;
    if (loc.startsWith(AppRoutes.profile))   return 3;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(AppRoutes.home); break;
      case 1: context.go(AppRoutes.search); break;
      case 2: context.go(AppRoutes.myTickets); break;
      case 3: context.go(AppRoutes.profile); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: _AppBottomNav(
        currentIndex: currentIndex,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }
}

/// Standalone bottom nav bar — used by non-shell screens (detail, checkout, etc.)
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavBar({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return _AppBottomNav(
      currentIndex: currentIndex,
      onTap: (i) {
        switch (i) {
          case 0: context.go(AppRoutes.home); break;
          case 1: context.go(AppRoutes.search); break;
          case 2: context.go(AppRoutes.myTickets); break;
          case 3: context.go(AppRoutes.profile); break;
        }
      },
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const _AppBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBg,
        selectedItemColor: AppColors.electricBlue,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w400),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num_outlined),
            activeIcon: Icon(Icons.confirmation_num_rounded),
            label: 'Tiket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
