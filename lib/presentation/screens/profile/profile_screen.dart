import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_router.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profil',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: auth.isLoggedIn
          ? _LoggedInProfile(auth: auth, ref: ref)
          : const _GuestProfile(),
    );
  }
}

// ── Guest ─────────────────────────────────────────────────────────────────────
class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                    color: AppColors.pageBg, shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border)),
                child: const Icon(Icons.person_rounded,
                    size: 32, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Text('Hai, Selamat Datang!',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Masuk atau daftar untuk pengalaman lebih baik.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.push(AppRoutes.login),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                      color: AppColors.electricBlue,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('Masuk / Daftar',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          _MenuItem(icon: Icons.help_outline_rounded, label: 'Bantuan'),
          _MenuItem(icon: Icons.info_outline_rounded,
              label: 'Tentang Aplikasi'),
        ],
      );
}

// ── Logged In ─────────────────────────────────────────────────────────────────
class _LoggedInProfile extends StatelessWidget {
  final AuthState auth;
  final WidgetRef ref;
  const _LoggedInProfile({required this.auth, required this.ref});

  // ── Konfirmasi logout ──────────────────────────────────────────────────────
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          // Icon
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded,
                color: AppColors.errorRed, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Keluar dari Akun?',
              style: GoogleFonts.poppins(
                  fontSize: 17, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Kamu akan keluar dari akun ini.\nYakin ingin melanjutkan?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary,
                height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(children: [
            // Batal
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.pageBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text('Batal',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Keluar
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('Keluar',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.user!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.deepIndigo, Color(0xFF2F3FA8)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle),
              child: Center(
                child: Text(user.initial,
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(user.name,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text(user.email,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(user.role.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        color: Colors.white, letterSpacing: 0.5)),
              ),
            ])),
          ]),
        ),
        const SizedBox(height: 16),

        // Info detail
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(children: [
            _InfoRow(icon: Icons.badge_outlined,
                label: 'Nama Lengkap', value: user.name),
            _InfoRow(icon: Icons.email_outlined,
                label: 'Email', value: user.email),
            _InfoRow(icon: Icons.admin_panel_settings_outlined,
                label: 'Role',
                value: user.role == 'admin' ? 'Administrator' : 'User',
                isLast: true),
          ]),
        ),
        const SizedBox(height: 12),

        _MenuItem(
          icon: Icons.confirmation_num_outlined,
          label: 'Tiket Saya',
          onTap: () => context.go(AppRoutes.myTickets),
        ),
        _MenuItem(
          icon: Icons.receipt_long_outlined,
          label: 'Riwayat Transaksi',
          onTap: () => context.go(AppRoutes.myTickets),
        ),
        _MenuItem(icon: Icons.help_outline_rounded, label: 'Bantuan'),
        _MenuItem(icon: Icons.info_outline_rounded,
            label: 'Tentang Aplikasi'),
        const SizedBox(height: 4),

        // Logout dengan konfirmasi dialog
        GestureDetector(
          onTap: () => _confirmLogout(context),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.errorRed.withOpacity(0.2), width: 0.5),
            ),
            child: Row(children: [
              const Icon(Icons.logout_rounded,
                  size: 20, color: AppColors.errorRed),
              const SizedBox(width: 12),
              Text('Keluar',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.errorRed)),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.errorRed),
            ]),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isLast;
  const _InfoRow({required this.icon, required this.label,
      required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: AppColors.textSecondary)),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ]),
          ]),
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 0.5,
              indent: 16, color: AppColors.border),
      ]);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary))),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textSecondary),
          ]),
        ),
      );
}
