import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/main_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).clearError();

    // POST /api/auth/register → { name, email, password, password_confirmation }
    final ok = await ref.read(authProvider.notifier).register(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      // Registrasi sekaligus login — langsung ke home
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                  color: AppColors.successGreenLight,
                  shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.successGreen, size: 34),
            ),
            const SizedBox(height: 16),
            Text('Registrasi Berhasil!',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(
              'Akun kamu telah dibuat.\nKamu sudah otomatis masuk.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.home);
                },
                child: const Text('Mulai Jelajahi Event'),
              ),
            ),
          ]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
      appBar: AppBar(
        title: Text('Buat Akun Baru',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppColors.pageBg,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 4),
            Text('Lengkapi data diri kamu.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            // Nama Lengkap
            const FieldLabel('Nama Lengkap'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icon(Icons.badge_outlined, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Nama lengkap wajib diisi';
                if (v.trim().length < 3)
                  return 'Nama minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Email
            const FieldLabel('Email'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'contoh@email.com',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Email wajib diisi';
                if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$')
                    .hasMatch(v.trim()))
                  return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password
            const FieldLabel('Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                hintText: 'Minimal 8 karakter',
                prefixIcon:
                    const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  child: Icon(
                    _obscurePass ? Icons.visibility_off_outlined
                                 : Icons.visibility_outlined,
                    size: 20, color: AppColors.textSecondary,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password wajib diisi';
                if (v.length < 8)
                  return 'Password minimal 8 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Konfirmasi Password
            const FieldLabel('Konfirmasi Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                hintText: 'Ulangi password',
                prefixIcon:
                    const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                      () => _obscureConfirm = !_obscureConfirm),
                  child: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20, color: AppColors.textSecondary,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty)
                  return 'Konfirmasi password wajib diisi';
                if (v != _passCtrl.text)
                  return 'Password tidak cocok';
                return null;
              },
            ),

            // Error dari API (email sudah terdaftar dll)
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              ErrorBanner(auth.error!),
            ],

            const SizedBox(height: 28),
            PrimaryButton(
              label: auth.isLoading
                  ? 'Mendaftarkan...'
                  : 'Daftar Sekarang',
              onTap: auth.isLoading ? null : _doRegister,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.pop(),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text('Sudah punya akun? ',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary)),
                Text('Masuk',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.electricBlue)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
