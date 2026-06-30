import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class PromoBanner extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback? onTap;

  const PromoBanner({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.deepIndigo, Color(0xFF2F3FA8)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -16, top: -16,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonPink.withOpacity(0.28),
                ),
              ),
            ),
            Positioned(
              right: 24, bottom: -20,
              child: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.electricBlue.withOpacity(0.35),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.festivalOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: Colors.white, letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: Colors.white, height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11, color: Colors.white.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ctaText,
                    style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
