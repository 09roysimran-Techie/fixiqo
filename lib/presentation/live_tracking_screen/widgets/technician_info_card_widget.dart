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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Technician avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2.5),
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: technician['imageUrl'] as String,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        semanticLabel: technician['semanticLabel'] as String,
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
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white, width: 1.5),
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            technician['badge'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      technician['specialty'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppTheme.warning,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${technician['rating']}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '· ${technician['completedJobs']} jobs',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
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

          // ETA + distance stats
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  icon: Icons.bolt_rounded,
                  label: 'Arrives in',
                  value: '$eta min',
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatChip(
                  icon: Icons.near_me_rounded,
                  label: 'Distance',
                  value: distance,
                  color: AppTheme.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatChip(
                  icon: Icons.verified_rounded,
                  label: 'Rating',
                  value: '${technician['rating']}★',
                  color: AppTheme.warning,
                ),
              ),
            ],
          ),
        ],
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
              color: AppTheme.secondary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
