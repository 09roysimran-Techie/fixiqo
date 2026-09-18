import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationService _service = NotificationService.instance;
  late TabController _tabController;

  final List<NotificationCategory> _categories = NotificationCategory.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _service.addListener(_onChanged);
    _service.startListening();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _service.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalUnread = _service.unreadCount;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(totalUnread),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories
                  .map(
                    (cat) =>
                        _NotificationList(category: cat, service: _service),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int totalUnread) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.secondary,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppTheme.secondary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Text(
            'Notifications',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondary,
            ),
          ),
          if (totalUnread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$totalUnread',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (totalUnread > 0)
          TextButton(
            onPressed: () => _service.markAllAsRead(),
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.outlineLight),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppTheme.primary,
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: AppTheme.primary,
        indicatorWeight: 2.5,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _categories.map((cat) {
          final unread = _service.unreadCountForCategory(cat);
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.label),
                if (unread > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$unread',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Notification List per Category ────────────────────────────────────────

class _NotificationList extends StatelessWidget {
  final NotificationCategory category;
  final NotificationService service;

  const _NotificationList({required this.category, required this.service});

  @override
  Widget build(BuildContext context) {
    final items = service.forCategory(category);

    if (items.isEmpty) {
      return _EmptyState(category: category);
    }

    // Group by date
    final grouped = _groupByDate(items);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped[index];
        if (entry is String) {
          // Date header
          return _DateHeader(label: entry);
        }
        final notification = entry as AppNotification;
        return _NotificationCard(
          notification: notification,
          onTap: () {
            if (!notification.isRead) {
              service.markAsRead(notification.id);
            }
          },
        );
      },
    );
  }

  List<dynamic> _groupByDate(List<AppNotification> notifications) {
    final result = <dynamic>[];
    String? lastLabel;

    for (final n in notifications) {
      final label = _dateLabel(n.createdAt);
      if (label != lastLabel) {
        result.add(label);
        lastLabel = label;
      }
      result.add(n);
    }
    return result;
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

// ─── Date Header ────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF94A3B8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Notification Card ───────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final config = _NotificationConfig.forType(notification.notificationType);

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: notification.isRead
            ? Colors.transparent
            : config.color.withAlpha(10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon bubble
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: config.color.withAlpha(22),
                shape: BoxShape.circle,
              ),
              child: Icon(config.icon, color: config.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(width: 8),
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
                  Row(
                    children: [
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: config.color.withAlpha(18),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          config.label,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: config.color,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Unread dot
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B35),
                            shape: BoxShape.circle,
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
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }
}

// ─── Notification Config ─────────────────────────────────────────────────────

class _NotificationConfig {
  final IconData icon;
  final Color color;
  final String label;

  const _NotificationConfig({
    required this.icon,
    required this.color,
    required this.label,
  });

  static _NotificationConfig forType(String type) {
    switch (type) {
      case NotificationType.newJobAlert:
        return const _NotificationConfig(
          icon: Icons.work_rounded,
          color: Color(0xFF3B82F6),
          label: 'Job Alert',
        );
      case NotificationType.jobAccepted:
        return const _NotificationConfig(
          icon: Icons.engineering_rounded,
          color: Color(0xFF10B981),
          label: 'Job Assigned',
        );
      case NotificationType.jobStarted:
        return const _NotificationConfig(
          icon: Icons.directions_run_rounded,
          color: Color(0xFFF59E0B),
          label: 'Job Started',
        );
      case NotificationType.jobCompleted:
        return const _NotificationConfig(
          icon: Icons.celebration_rounded,
          color: Color(0xFF00C896),
          label: 'Completed',
        );
      case NotificationType.jobCancelled:
        return const _NotificationConfig(
          icon: Icons.cancel_rounded,
          color: Color(0xFFEF4444),
          label: 'Cancelled',
        );
      case NotificationType.bookingConfirmed:
        return const _NotificationConfig(
          icon: Icons.bookmark_added_rounded,
          color: Color(0xFF8B5CF6),
          label: 'Booking',
        );
      case NotificationType.paymentReceived:
        return const _NotificationConfig(
          icon: Icons.payments_rounded,
          color: Color(0xFF10B981),
          label: 'Payment',
        );
      default:
        return const _NotificationConfig(
          icon: Icons.notifications_rounded,
          color: Color(0xFF64748B),
          label: 'Alert',
        );
    }
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final NotificationCategory category;
  const _EmptyState({required this.category});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;

    switch (category) {
      case NotificationCategory.bookingUpdates:
        icon = Icons.bookmark_border_rounded;
        message =
            'No booking updates yet.\nYour booking activity will appear here.';
        break;
      case NotificationCategory.jobAssignments:
        icon = Icons.work_outline_rounded;
        message = 'No job assignments yet.\nNew job alerts will appear here.';
        break;
      case NotificationCategory.alerts:
        icon = Icons.notifications_none_rounded;
        message = 'No alerts at the moment.\nSystem alerts will appear here.';
        break;
      default:
        icon = Icons.notifications_none_rounded;
        message =
            'No notifications yet.\nWe\'ll notify you when something happens.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
