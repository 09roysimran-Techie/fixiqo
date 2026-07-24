import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class JobStatusTimelineWidget extends StatefulWidget {
  final int currentStatusIndex;

  const JobStatusTimelineWidget({required this.currentStatusIndex, super.key});

  @override
  State<JobStatusTimelineWidget> createState() =>
      _JobStatusTimelineWidgetState();
}

class _JobStatusTimelineWidgetState extends State<JobStatusTimelineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  final List<Map<String, dynamic>> _stages = [
    {
      'label': 'Booking Confirmed',
      'icon': Icons.check_circle_outline_rounded,
      'time': '9:41 AM',
    },
    {
      'label': 'Technician Assigned',
      'icon': Icons.person_pin_rounded,
      'time': '9:43 AM',
    },
    {
      'label': 'En Route to You',
      'icon': Icons.directions_car_rounded,
      'time': '9:45 AM',
    },
    {
      'label': 'Technician Arrived',
      'icon': Icons.location_on_rounded,
      'time': 'Est. 9:59 AM',
    },
    {
      'label': 'Repair In Progress',
      'icon': Icons.build_rounded,
      'time': 'Pending',
    },
    {
      'label': 'Job Completed',
      'icon': Icons.task_alt_rounded,
      'time': 'Pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

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
            color: Colors.black.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Status',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_stages.length, (i) {
            final stage = _stages[i];
            final isCompleted = i < widget.currentStatusIndex;
            final isCurrent = i == widget.currentStatusIndex;
            final isPending = i > widget.currentStatusIndex;
            final isLast = i == _stages.length - 1;

            return _TimelineItem(
              label: stage['label'] as String,
              icon: stage['icon'] as IconData,
              time: stage['time'] as String,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isPending: isPending,
              isLast: isLast,
              progressAnim: _progressAnim,
              animIndex: i,
              currentIndex: widget.currentStatusIndex,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String time;
  final bool isCompleted;
  final bool isCurrent;
  final bool isPending;
  final bool isLast;
  final Animation<double> progressAnim;
  final int animIndex;
  final int currentIndex;

  const _TimelineItem({
    required this.label,
    required this.icon,
    required this.time,
    required this.isCompleted,
    required this.isCurrent,
    required this.isPending,
    required this.isLast,
    required this.progressAnim,
    required this.animIndex,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line + icon column
        SizedBox(
          width: 32,
          child: Column(
            children: [
              // Node
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.primary
                      : isCurrent
                      ? AppTheme.primary.withAlpha(38)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: AppTheme.primary, width: 2)
                      : Border.all(color: Colors.transparent),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : icon,
                  size: 16,
                  color: isCompleted
                      ? Colors.white
                      : isCurrent
                      ? AppTheme.primary
                      : const Color(0xFFCBD5E1),
                ),
              ),
              // Connector line
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 2,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.primary
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isPending
                              ? const Color(0xFFCBD5E1)
                              : AppTheme.secondary,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Current Stage',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: isPending
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF94A3B8),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
