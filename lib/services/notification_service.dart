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

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Start listening for real-time notifications for a given recipient
  void startListening(String recipientId) {
    if (_isListening) return;
    _isListening = true;

    // Load existing notifications first
    _loadNotifications(recipientId);

    // Subscribe to real-time inserts
    _channel = _client
        .channel('notifications:$recipientId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_id',
            value: recipientId,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty) {
              final notification = AppNotification.fromJson(newRecord);
              _notifications.insert(0, notification);
              notifyListeners();
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
          .limit(50);

      _notifications.clear();
      for (final item in response as List) {
        _notifications.add(
          AppNotification.fromJson(item as Map<String, dynamic>),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationService: Failed to load notifications: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('NotificationService: Failed to mark as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String recipientId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', recipientId)
          .eq('is_read', false);

      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      notifyListeners();
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
