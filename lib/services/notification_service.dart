import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

/// Notification model
class AppNotification {
  final String id;
  final String recipientId;
  final String? senderId;
  final String notificationType;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.recipientId,
    this.senderId,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      recipientId: json['recipient_id'] as String? ?? '',
      senderId: json['sender_id'] as String?,
      notificationType: json['notification_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      recipientId: recipientId,
      senderId: senderId,
      notificationType: notificationType,
      title: title,
      body: body,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

/// Notification types
class NotificationType {
  static const String newJobAlert = 'new_job_alert';
  static const String jobAccepted = 'job_accepted';
  static const String jobStarted = 'job_started';
  static const String jobCompleted = 'job_completed';
  static const String jobCancelled = 'job_cancelled';
  static const String bookingConfirmed = 'booking_confirmed';
  static const String paymentReceived = 'payment_received';

  /// Returns the category for a given notification type
  static NotificationCategory categoryFor(String type) {
    switch (type) {
      case bookingConfirmed:
      case jobCompleted:
      case jobCancelled:
      case paymentReceived:
        return NotificationCategory.bookingUpdates;
      case newJobAlert:
      case jobAccepted:
      case jobStarted:
        return NotificationCategory.jobAssignments;
      default:
        return NotificationCategory.alerts;
    }
  }
}

enum NotificationCategory {
  all,
  bookingUpdates,
  jobAssignments,
  alerts;

  String get label {
    switch (this) {
      case all:
        return 'All';
      case bookingUpdates:
        return 'Bookings';
      case jobAssignments:
        return 'Jobs';
      case alerts:
        return 'Alerts';
    }
  }
}

/// Service for managing real-time notifications via Supabase
class NotificationService extends ChangeNotifier {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  final List<AppNotification> _notifications = [];
  RealtimeChannel? _channel;
  bool _isListening = false;
  String? _currentRecipientId;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Returns notifications filtered by category
  List<AppNotification> forCategory(NotificationCategory category) {
    if (category == NotificationCategory.all) return notifications;
    return _notifications
        .where(
          (n) => NotificationType.categoryFor(n.notificationType) == category,
        )
        .toList();
  }

  /// Unread count for a specific category
  int unreadCountForCategory(NotificationCategory category) {
    return forCategory(category).where((n) => !n.isRead).length;
  }

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Returns the current user's ID or falls back to demo ID
  String get _effectiveRecipientId {
    final user = _client.auth.currentUser;
    return user?.id ?? 'demo-homeowner-001';
  }

  /// Start listening for real-time notifications for a given recipient.
  /// If [recipientId] is null, uses the authenticated user or demo ID.
  void startListening([String? recipientId]) {
    final id = recipientId ?? _effectiveRecipientId;

    // If already listening for the same recipient, skip
    if (_isListening && _currentRecipientId == id) return;

    // Stop previous subscription if switching recipient
    if (_isListening) stopListening();

    _isListening = true;
    _currentRecipientId = id;

    // Load existing notifications first
    _loadNotifications(id);

    // Subscribe to real-time inserts and updates
    _channel = _client
        .channel('notifications:$id')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_id',
            value: id,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty) {
              final notification = AppNotification.fromJson(newRecord);
              // Avoid duplicates
              if (!_notifications.any((n) => n.id == notification.id)) {
                _notifications.insert(0, notification);
                notifyListeners();
              }
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_id',
            value: id,
          ),
          callback: (payload) {
            final updated = payload.newRecord;
            if (updated.isNotEmpty) {
              final updatedNotif = AppNotification.fromJson(updated);
              final index = _notifications.indexWhere(
                (n) => n.id == updatedNotif.id,
              );
              if (index != -1) {
                _notifications[index] = updatedNotif;
                notifyListeners();
              }
            }
          },
        )
        .subscribe();
  }

  /// Load existing notifications from Supabase
  Future<void> _loadNotifications(String recipientId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('recipient_id', recipientId)
          .order('created_at', ascending: false)
          .limit(100);

      _notifications.clear();
      for (final item in response as List) {
        _notifications.add(
          AppNotification.fromJson(item as Map<String, dynamic>),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationService: Failed to load notifications: $e');
      // Seed demo notifications for preview
      _seedDemoNotifications();
    }
  }

  void _seedDemoNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
      AppNotification(
        id: 'demo-1',
        recipientId: 'demo-homeowner-001',
        notificationType: NotificationType.bookingConfirmed,
        title: '✅ Booking Confirmed!',
        body: 'Your AC Repair booking has been confirmed for today at 3:00 PM.',
        data: {'booking_id': 'bk-001', 'service': 'AC Repair'},
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      AppNotification(
        id: 'demo-2',
        recipientId: 'demo-homeowner-001',
        notificationType: NotificationType.jobAccepted,
        title: '🔧 Technician Assigned!',
        body: 'Rajesh Kumar has accepted your Plumbing booking.',
        data: {
          'booking_id': 'bk-002',
          'technician_name': 'Rajesh Kumar',
          'service': 'Plumbing',
        },
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 22)),
      ),
      AppNotification(
        id: 'demo-3',
        recipientId: 'demo-homeowner-001',
        notificationType: NotificationType.newJobAlert,
        title: '🔔 New Job Alert!',
        body: 'Electrical Wiring job at Andheri West — ₹1,200',
        data: {
          'booking_id': 'bk-003',
          'service': 'Electrical Wiring',
          'amount': 1200,
        },
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'demo-4',
        recipientId: 'demo-homeowner-001',
        notificationType: NotificationType.jobCompleted,
        title: '🎉 Job Completed!',
        body: 'Your Washing Machine Repair has been completed successfully.',
        data: {'booking_id': 'bk-004', 'service': 'Washing Machine Repair'},
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'demo-5',
        recipientId: 'demo-homeowner-001',
        notificationType: NotificationType.paymentReceived,
        title: '💳 Payment Received',
        body: 'Payment of ₹850 received for Plumbing service.',
        data: {'booking_id': 'bk-005', 'amount': 850},
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'demo-6',
        recipientId: 'demo-homeowner-001',
        notificationType: NotificationType.jobStarted,
        title: '🚗 Technician On The Way!',
        body: 'Amit Sharma is heading to your location for Carpenter service.',
        data: {
          'booking_id': 'bk-006',
          'technician_name': 'Amit Sharma',
          'service': 'Carpenter',
        },
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
    notifyListeners();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    // Optimistic update
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('NotificationService: Failed to mark as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead([String? recipientId]) async {
    final id = recipientId ?? _currentRecipientId ?? _effectiveRecipientId;
    // Optimistic update
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', id)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('NotificationService: Failed to mark all as read: $e');
    }
  }

  /// Send a notification (insert into Supabase — triggers real-time for recipient)
  Future<void> sendNotification({
    required String recipientId,
    String? senderId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.from('notifications').insert({
        'recipient_id': recipientId,
        if (senderId != null) 'sender_id': senderId,
        'notification_type': type,
        'title': title,
        'body': body,
        'data': data ?? {},
        'is_read': false,
      });
    } catch (e) {
      debugPrint('NotificationService: Failed to send notification: $e');
    }
  }

  /// Send new job alert to technician
  Future<void> notifyTechnicianNewJob({
    required String technicianId,
    required String service,
    required String address,
    required String bookingId,
    required int amount,
  }) async {
    await sendNotification(
      recipientId: technicianId,
      type: NotificationType.newJobAlert,
      title: '🔧 New Job Alert!',
      body: '$service at $address — ₹$amount',
      data: {
        'booking_id': bookingId,
        'service': service,
        'address': address,
        'amount': amount,
      },
    );
  }

  /// Send booking status update to homeowner
  Future<void> notifyHomeownerStatusUpdate({
    required String homeownerId,
    required String status,
    required String service,
    required String bookingId,
    String? technicianName,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'accepted':
        title = '✅ Technician Assigned!';
        body =
            '${technicianName ?? 'Your technician'} has accepted your $service booking.';
        break;
      case 'en_route':
        title = '🚗 Technician On The Way!';
        body =
            '${technicianName ?? 'Your technician'} is heading to your location.';
        break;
      case 'arrived':
        title = '📍 Technician Arrived!';
        body =
            '${technicianName ?? 'Your technician'} has arrived at your location.';
        break;
      case 'in_progress':
        title = '🔨 Work In Progress';
        body = 'Your $service is currently being worked on.';
        break;
      case 'completed':
        title = '🎉 Job Completed!';
        body = 'Your $service has been completed successfully.';
        break;
      case 'cancelled':
        title = '❌ Booking Cancelled';
        body = 'Your $service booking has been cancelled.';
        break;
      default:
        title = '📋 Booking Update';
        body = 'Your $service booking status has been updated.';
    }

    await sendNotification(
      recipientId: homeownerId,
      type: _statusToNotificationType(status),
      title: title,
      body: body,
      data: {
        'booking_id': bookingId,
        'status': status,
        'service': service,
        if (technicianName != null) 'technician_name': technicianName,
      },
    );
  }

  String _statusToNotificationType(String status) {
    switch (status) {
      case 'accepted':
        return NotificationType.jobAccepted;
      case 'in_progress':
        return NotificationType.jobStarted;
      case 'completed':
        return NotificationType.jobCompleted;
      case 'cancelled':
        return NotificationType.jobCancelled;
      default:
        return NotificationType.bookingConfirmed;
    }
  }

  /// Stop listening and clean up
  void stopListening() {
    _channel?.unsubscribe();
    _channel = null;
    _isListening = false;
    _currentRecipientId = null;
  }

  /// Clear all local notifications
  void clearLocal() {
    _notifications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
