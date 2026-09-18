import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class SpecialistCardWidget extends StatefulWidget {
  final Map<String, dynamic> specialist;
  final VoidCallback onBookNow;

  const SpecialistCardWidget({
    required this.specialist,
    required this.onBookNow,
    super.key,
  });

  @override
  State<SpecialistCardWidget> createState() => _SpecialistCardWidgetState();
}

class _SpecialistCardWidgetState extends State<SpecialistCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.specialist;
    final bool available = s['available'] as bool;
    final String? badge = s['badge'] as String?;

    return ScaleTransition(
      scale: _pressController,
      child: GestureDetector(
        onTapDown: (_) => _pressController.reverse(),
        onTapUp: (_) => _pressController.forward(),
        onTapCancel: () => _pressController.forward(),
        child: Container(
          width: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFF00C896).withAlpha(10),
                blurRadius: 24,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                    child: Stack(
                      children: [
                        CustomImageWidget(
                          imageUrl: s['imageUrl'] as String,
                          width: double.infinity,
                          height: 148,
                          fit: BoxFit.cover,
                          semanticLabel: s['semanticLabel'] as String,
                        ),
                        // Gradient overlay on image
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withAlpha(120),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge
                  if (badge != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // ETA chip top-right
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.white.withAlpha(30),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: available
                                  ? const Color(0xFF00C896)
                                  : Colors.white.withAlpha(80),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            available ? s['eta'] as String : 'Busy',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Info section
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + specialty
                    Text(
                      s['name'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00C896).withAlpha(180),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          s['specialty'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF00C896),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Rating + distance row
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${s['rating']}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${s['reviews']})',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          s['distance'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Divider
                    Container(height: 1, color: const Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    // Price + Book
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${s['price']}',
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A2E),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'starting',
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: available ? widget.onBookNow : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              gradient: available
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF00C896),
                                        Color(0xFF00A87A),
                                      ],
                                    )
                                  : null,
                              color: available ? null : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: available
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00C896,
                                        ).withAlpha(70),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              available ? 'Book Now' : 'Busy',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: available
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
