import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/main_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectPath;
  const LoginScreen({super.key, this.redirectPath});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final input    = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (input.isEmpty || password.isEmpty) {
      ref.read(authProvider.notifier);
      return;
    }

    // Backend hanya support email login (users.email unique)
    // Jika user input tanpa @, kita kirim apa adanya dan biarkan backend validasi
    final ok = await ref.read(authProvider.notifier).login(input, password);
    if (!mounted) return;
    if (ok) {
      if (widget.redirectPath != null) {
        context.go(widget.redirectPath!);
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppColors.pageBg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          Text('Masuk ke Akunmu 👋',
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Gunakan email yang terdaftar.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 28),

          const FieldLabel('Email'),
          const SizedBox(height: 6),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _doLogin(),
            decoration: const InputDecoration(
              hintText: 'contoh: user@gmail.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 14),

          const FieldLabel('Password'),
          const SizedBox(height: 6),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            onSubmitted: (_) => _doLogin(),
            decoration: InputDecoration(
              hintText: 'Masukkan password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure ? Icons.visibility_off_outlined
                           : Icons.visibility_outlined,
                  size: 20, color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // Error dari API
          if (auth.error != null) ...[
            const SizedBox(height: 10),
            ErrorBanner(auth.error!),
          ],

          const SizedBox(height: 24),
          PrimaryButton(
            label: auth.isLoading ? 'Masuk...' : 'Masuk',
            onTap: auth.isLoading ? null : _doLogin,
          ),

          const SizedBox(height: 20),
          Row(children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('atau',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
            const Expanded(child: Divider()),
          ]),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => context.push(AppRoutes.register),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Belum punya akun? ',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
              Text('Daftar Sekarang',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.electricBlue)),
            ]),
          ),
        ]),
      ),
    );
  }
}
