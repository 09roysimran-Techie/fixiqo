import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService.instance;

  // Demo recipient ID for preview (in production, use auth.currentUser.id)
  static const String _demoRecipientId = 'demo-homeowner-001';

  @override
  void initState() {
    super.initState();
    _notificationService.addListener(_onNotificationsChanged);
    if (!_notificationService.notifications.isNotEmpty) {
      _notificationService.startListening(_demoRecipientId);
    }
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;
    final unreadCount = _notificationService.unreadCount;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Notifications',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF1A1A2E),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () =>
                  _notificationService.markAllAsRead(_demoRecipientId),
              child: Text(
                'Mark all read',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
        ],
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? _EmptyNotifications()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 72,
                endIndent: 20,
                color: AppTheme.outlineLight,
              ),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () {
                    if (!notification.isRead) {
                      _notificationService.markAsRead(notification.id);
                    }
                  },
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : AppTheme.primary.withAlpha(12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationIcon(type: notification.notificationType),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppTheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
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

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _NotificationIcon extends StatelessWidget {
  final String type;

  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case 'new_job_alert':
        icon = Icons.work_rounded;
        color = AppTheme.info;
        break;
      case 'job_accepted':
        icon = Icons.check_circle_rounded;
        color = AppTheme.success;
        break;
      case 'job_started':
        icon = Icons.engineering_rounded;
        color = AppTheme.warning;
        break;
      case 'job_completed':
        icon = Icons.celebration_rounded;
        color = AppTheme.primary;
        break;
      case 'job_cancelled':
        icon = Icons.cancel_rounded;
        color = AppTheme.error;
        break;
      case 'booking_confirmed':
        icon = Icons.bookmark_added_rounded;
        color = AppTheme.primary;
        break;
      case 'payment_received':
        icon = Icons.payments_rounded;
        color = AppTheme.success;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppTheme.secondary;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No notifications yet',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Job alerts and booking updates\nwill appear here in real-time.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
