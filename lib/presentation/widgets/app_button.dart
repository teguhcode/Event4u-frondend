// lib/presentation/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.electricBlue,
          borderRadius: BorderRadius.circular(14),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: (backgroundColor ?? AppColors.electricBlue)
                        .withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor ?? Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
