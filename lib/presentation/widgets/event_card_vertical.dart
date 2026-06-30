import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class EventCardVertical extends StatefulWidget {
  final int eventId;
  final String name;
  final String date;
  final String time;
  final String price;
  final String emoji;
  final String? imageUrl;
  final Color bgColor;
  final VoidCallback? onTap;

  const EventCardVertical({
    super.key,
    required this.eventId,
    required this.name,
    required this.date,
    required this.time,
    required this.price,
    required this.emoji,
    this.imageUrl,
    required this.bgColor,
    this.onTap,
  });

  @override
  State<EventCardVertical> createState() => _EventCardVerticalState();
}

class _EventCardVerticalState extends State<EventCardVertical> {
  bool _isFavorited = false;

  // Header wajib untuk bypass ngrok warning page
  static const Map<String, String> _imgHeaders = {
    'ngrok-skip-browser-warning': 'true',
    'Accept': 'image/*',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18)),
            child: SizedBox(
              width: 80, height: 90,
              child: _buildImage(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, height: 1.3),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 11, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${widget.date} · ${widget.time}',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.price,
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: AppColors.electricBlue)),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isFavorited = !_isFavorited),
                        child: Icon(
                          _isFavorited
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: _isFavorited
                              ? AppColors.errorRed
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildImage() {
    final url = widget.imageUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        httpHeaders: _imgHeaders,
        fit: BoxFit.cover,
        placeholder: (_, __) => _fallback(),
        errorWidget: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        color: widget.bgColor,
        child: Center(
            child: Text(widget.emoji,
                style: const TextStyle(fontSize: 28))),
      );
}
