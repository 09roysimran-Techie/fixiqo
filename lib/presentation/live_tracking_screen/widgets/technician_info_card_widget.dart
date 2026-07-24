import 'dart:ui';

import '../../../core/app_export.dart';

class TechnicianInfoCardWidget extends StatelessWidget {
  final Map<String, dynamic> technician;
  final int eta;
  final String distance;

  const TechnicianInfoCardWidget({
    required this.technician,
    required this.eta,
    required this.distance,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1C2E).withAlpha(235),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00C896).withAlpha(51),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C896).withAlpha(15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Technician avatar with teal glow ring
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C896), Color(0xFF009B74)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C896).withAlpha(102),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.5),
                          child: ClipOval(
                            child: CustomImageWidget(
                              imageUrl: technician['imageUrl'] as String,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              semanticLabel:
                                  technician['semanticLabel'] as String,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C896), Color(0xFF009B74)],
                            ),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFF0D1B2A),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            '✓',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Name + specialty + rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                technician['name'] as String,
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE2E8F0),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C896).withAlpha(38),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: const Color(0xFF00C896).withAlpha(77),
                                  width: 0.5,
                                ),
                              ),
                              child: const Text(
                                'Certified',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00C896),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          technician['specialty'] as String,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: Color(0xFF64A89A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${technician['rating']}',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE2E8F0),
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '· ${technician['completedJobs']} jobs',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: Color(0xFF4A6580),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF00C896).withAlpha(51),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ETA + distance stats
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.bolt_rounded,
                      label: 'Arrives in',
                      value: '$eta min',
                      color: const Color(0xFF00C896),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.near_me_rounded,
                      label: 'Distance',
                      value: distance,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.verified_rounded,
                      label: 'Rating',
                      value: '${technician['rating']}★',
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10,
              color: Color(0xFF4A6580),
            ),
          ),
        ],
      ),
    );
  }
}
