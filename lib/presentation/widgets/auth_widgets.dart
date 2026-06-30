import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary));
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const PrimaryButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.electricBlue
              : AppColors.electricBlue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: onTap != null
              ? [BoxShadow(
                  color: AppColors.electricBlue.withOpacity(0.35),
                  blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.errorRed, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}
