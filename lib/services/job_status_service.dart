import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

/// Job status values matching the DB and UI
class JobStatusValue {
  static const String accepted = 'accepted';
  static const String enRoute = 'en_route';
  static const String arrived = 'arrived';
  static const String inService = 'in_service';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

/// Model for a job status update record
class JobStatusUpdate {
  final String id;
  final String jobId;
  final String? bookingId;
  final String? partnerId;
  final String? customerId;
  final String status;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  JobStatusUpdate({
    required this.id,
    required this.jobId,
    this.bookingId,
    this.partnerId,
    this.customerId,
    required this.status,
    required this.updatedAt,
    required this.metadata,
  });

  factory JobStatusUpdate.fromJson(Map<String, dynamic> json) {
    return JobStatusUpdate(
      id: json['id'] as String? ?? '',
      jobId: json['job_id'] as String? ?? '',
      bookingId: json['booking_id'] as String?,
      partnerId: json['partner_id'] as String?,
      customerId: json['customer_id'] as String?,
      status: json['status'] as String? ?? JobStatusValue.accepted,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// Service for publishing and subscribing to real-time job status changes.
///
/// Usage:
///   Partner side: call [publishStatus] when advancing job status.
///   Customer side: call [subscribeToJob] to receive live updates.
class JobStatusService extends ChangeNotifier {
  static JobStatusService? _instance;
  static JobStatusService get instance => _instance ??= JobStatusService._();

  JobStatusService._();

  String? _currentStatus;
  String? _subscribedJobId;
  RealtimeChannel? _channel;

  /// Latest status received from real-time subscription
  String? get currentStatus => _currentStatus;

  SupabaseClient get _client => SupabaseService.instance.client;

  // ──────────────────────────────────────────────────────────────
  // PARTNER SIDE: Publish a status change to Supabase
  // ──────────────────────────────────────────────────────────────

  /// Called by the partner when they advance the job status.
  /// Upserts the latest status row for [jobId].
  Future<void> publishStatus({
    required String jobId,
    required String status,
    String? bookingId,
    String? partnerId,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _client.from('job_status_updates').upsert({
        'job_id': jobId,
        if (bookingId != null) 'booking_id': bookingId,
        if (partnerId != null) 'partner_id': partnerId,
        if (customerId != null) 'customer_id': customerId,
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
        'metadata': metadata ?? {},
      }, onConflict: 'job_id');
    } catch (e) {
      debugPrint('JobStatusService: Failed to publish status: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // CUSTOMER SIDE: Subscribe to live status updates for a job
  // ──────────────────────────────────────────────────────────────

  /// Subscribe to real-time status changes for [jobId].
  /// [onStatusChanged] is called whenever the status changes.
  void subscribeToJob({
    required String jobId,
    required void Function(String status) onStatusChanged,
  }) {
    // Avoid duplicate subscriptions for the same job
    if (_subscribedJobId == jobId && _channel != null) return;

    // Unsubscribe from any previous job
    unsubscribe();

    _subscribedJobId = jobId;

    _channel = _client
        .channel('job_status:$jobId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'job_status_updates',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'job_id',
            value: jobId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              final newStatus = record['status'] as String?;
              if (newStatus != null && newStatus != _currentStatus) {
                _currentStatus = newStatus;
                notifyListeners();
                onStatusChanged(newStatus);
              }
            }
          },
        )
        .subscribe();
  }

  /// Fetch the latest status for [jobId] from Supabase (one-time read).
  Future<String?> fetchLatestStatus(String jobId) async {
    try {
      final response = await _client
          .from('job_status_updates')
          .select('status, updated_at')
          .eq('job_id', jobId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return response['status'] as String?;
      }
    } catch (e) {
      debugPrint('JobStatusService: Failed to fetch status: $e');
    }
    return null;
  }

  /// Unsubscribe from the current real-time channel.
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
    _subscribedJobId = null;
    _currentStatus = null;
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}
