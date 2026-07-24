import 'dart:ui';
import 'package:flutter/material.dart';

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
              color: const Color(0xFF00C896).withAlpha(38),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF00C896), Color(0xFF009B74)],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Job Status',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ],
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
        ),
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
                  gradient: isCompleted
                      ? const LinearGradient(
                          colors: [Color(0xFF00C896), Color(0xFF009B74)],
                        )
                      : null,
                  color: isCompleted
                      ? null
                      : isCurrent
                      ? const Color(0xFF00C896).withAlpha(38)
                      : const Color(0xFF1A2E40),
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: const Color(0xFF00C896), width: 2)
                      : isCompleted
                      ? null
                      : Border.all(color: const Color(0xFF2A3F55), width: 1),
                  boxShadow: isCompleted || isCurrent
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00C896).withAlpha(77),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : icon,
                  size: 16,
                  color: isCompleted
                      ? Colors.white
                      : isCurrent
                      ? const Color(0xFF00C896)
                      : const Color(0xFF2A3F55),
                ),
              ),
              // Connector line
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 2,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF00C896), Color(0xFF009B74)],
                          )
                        : null,
                    color: isCompleted ? null : const Color(0xFF1A2E40),
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
                              ? const Color(0xFF2A3F55)
                              : isCompleted
                              ? const Color(0xFF64A89A)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
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
                            'Current Stage',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00C896),
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
                        ? const Color(0xFF1A2E40)
                        : const Color(0xFF4A6580),
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
