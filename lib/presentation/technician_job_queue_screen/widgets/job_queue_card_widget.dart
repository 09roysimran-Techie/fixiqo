import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class JobQueueCardWidget extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const JobQueueCardWidget({
    super.key,
    required this.job,
    required this.isExpanded,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'Emergency':
        return AppTheme.error;
      case 'Urgent':
        return AppTheme.warning;
      default:
        return AppTheme.info;
    }
  }

  IconData _serviceIcon(String service) {
    switch (service) {
      case 'Plumbing':
        return Icons.plumbing_rounded;
      case 'AC Repair':
        return Icons.ac_unit_rounded;
      case 'Electrical':
        return Icons.electrical_services_rounded;
      case 'Locksmith':
        return Icons.lock_rounded;
      case 'Carpentry':
        return Icons.carpenter_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgency = job['urgency'] as String;
    final urgencyColor = _urgencyColor(urgency);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isExpanded
                ? AppTheme.primary.withAlpha(100)
                : AppTheme.outlineLight,
            width: isExpanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isExpanded ? 18 : 8),
              blurRadius: isExpanded ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: urgencyColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Icon(
                      _serviceIcon(job['service'] as String),
                      color: urgencyColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job['service'] as String,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppTheme.secondary,
                                  fontWeight: FontWeight.w700,
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
                                color: urgencyColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                urgency,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: urgencyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                job['address'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${job['price']}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        job['distance'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expanded details
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 260),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const Divider(height: 1, color: AppTheme.outlineVariantLight),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(
                                job['customerAvatar'] as String,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job['customerName'] as String,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: AppTheme.secondary,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < (job['customerRating'] as int)
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 12,
                                        color: AppTheme.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 12,
                                    color: AppTheme.primaryDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    job['eta'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Issue description
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            job['description'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Accept / Reject buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onReject,
                                icon: const Icon(Icons.close_rounded, size: 16),
                                label: const Text('Decline'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.error,
                                  side: const BorderSide(color: AppTheme.error),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: onAccept,
                                icon: const Icon(Icons.check_rounded, size: 16),
                                label: const Text('Accept Job'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}
