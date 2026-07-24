import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BookingStatus {
  searching,
  assigned,
  enRoute,
  arrived,
  inProgress,
  completed,
  cancelled,
}

class StatusBadgeWidget extends StatelessWidget {
  final BookingStatus status;
  final bool compact;

  const StatusBadgeWidget({
    required this.status,
    this.compact = false,
    super.key,
  });

  static Map<String, dynamic> _statusConfig(BookingStatus s) {
    switch (s) {
      case BookingStatus.searching:
        return {
          'label': 'Searching',
          'color': AppTheme.warning,
          'icon': Icons.search_rounded,
        };
      case BookingStatus.assigned:
        return {
          'label': 'Assigned',
          'color': AppTheme.info,
          'icon': Icons.person_pin_rounded,
        };
      case BookingStatus.enRoute:
        return {
          'label': 'En Route',
          'color': AppTheme.primary,
          'icon': Icons.directions_car_rounded,
        };
      case BookingStatus.arrived:
        return {
          'label': 'Arrived',
          'color': AppTheme.success,
          'icon': Icons.location_on_rounded,
        };
      case BookingStatus.inProgress:
        return {
          'label': 'In Progress',
          'color': AppTheme.secondary,
          'icon': Icons.build_rounded,
        };
      case BookingStatus.completed:
        return {
          'label': 'Completed',
          'color': AppTheme.success,
          'icon': Icons.check_circle_rounded,
        };
      case BookingStatus.cancelled:
        return {
          'label': 'Cancelled',
          'color': AppTheme.error,
          'icon': Icons.cancel_rounded,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    final color = config['color'] as Color;
    final label = config['label'] as String;
    final icon = config['icon'] as IconData;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withAlpha(77), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
