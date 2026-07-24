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
          width: 185,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image top — full width, locked anatomy
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: CustomImageWidget(
                      imageUrl: s['imageUrl'] as String,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      semanticLabel: s['semanticLabel'] as String,
                    ),
                  ),
                  // Badge top-left
                  if (badge != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Availability dot
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: available ? AppTheme.success : AppTheme.warning,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),

              // Info section
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      s['name'] as String,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Specialty
                    Text(
                      s['specialty'] as String,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Rating row
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppTheme.warning,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${s['rating']}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${s['reviews']})',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              s['eta'] as String,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Price + Book Now
                    Row(
                      children: [
                        Text(
                          '\$${s['price']}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: available ? widget.onBookNow : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: available
                                  ? AppTheme.primary
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              available ? 'Book Now' : 'Busy',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
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
