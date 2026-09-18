import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

/// Model for a booking/job shown in the technician job queue.
class TechnicianJob {
  final String id;
  final String bookingRef;
  final String service;
  final String address;
  final String urgency;
  final int price;
  final String distanceKm;
  final String etaMinutes;
  final String customerName;
  final String customerAvatarUrl;
  final int customerRating;
  final String description;
  final String status;
  final String? partnerId;
  final DateTime createdAt;

  TechnicianJob({
    required this.id,
    required this.bookingRef,
    required this.service,
    required this.address,
    required this.urgency,
    required this.price,
    required this.distanceKm,
    required this.etaMinutes,
    required this.customerName,
    required this.customerAvatarUrl,
    required this.customerRating,
    required this.description,
    required this.status,
    this.partnerId,
    required this.createdAt,
  });

  factory TechnicianJob.fromJson(Map<String, dynamic> json) {
    return TechnicianJob(
      id: json['id']?.toString() ?? '',
      bookingRef: json['booking_ref']?.toString() ?? '',
      service: json['service']?.toString() ?? 'Home Service',
      address: json['address']?.toString() ?? 'Bengaluru',
      urgency: json['urgency']?.toString() ?? 'Standard',
      price: (json['total_amount'] as num?)?.toInt() ?? 0,
      distanceKm: json['distance_km']?.toString() ?? '—',
      etaMinutes: json['eta_minutes']?.toString() ?? '—',
      customerName: json['customer_name']?.toString() ?? 'Customer',
      customerAvatarUrl:
          json['customer_avatar_url']?.toString() ??
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
      customerRating: (json['customer_rating'] as num?)?.toInt() ?? 4,
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      partnerId: json['partner_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJobMap() => {
    'id': id,
    'service': service,
    'urgency': urgency,
    'address': address,
    'price': price,
    'distance': distanceKm,
    'eta': etaMinutes,
    'customerName': customerName,
    'customerAvatar': customerAvatarUrl,
    'customerRating': customerRating,
    'description': description,
    'statusStep': 0,
  };
}

/// Service for fetching and managing technician job queue from Supabase.
class TechnicianJobService {
  static TechnicianJobService? _instance;
  static TechnicianJobService get instance =>
      _instance ??= TechnicianJobService._();

  TechnicianJobService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Fetches all pending (unassigned) bookings for the job queue.
  Future<List<TechnicianJob>> fetchPendingJobs() async {
    try {
      final response = await _client
          .from('bookings')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((row) => TechnicianJob.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      // ignore: avoid_print
      print('[TechnicianJobService] fetchPendingJobs error: ${e.message}');
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('[TechnicianJobService] fetchPendingJobs unexpected: $e');
      return [];
    }
  }

  /// Fetches bookings assigned to a specific partner (active/confirmed jobs).
  Future<List<TechnicianJob>> fetchAssignedJobs(String partnerId) async {
    try {
      var query = _client.from('bookings').select();
      query = query.eq('partner_id', partnerId);
      query = query.inFilter('status', [
        'confirmed',
        'assigned',
        'in_progress',
      ]);
      final response = await query.order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((row) => TechnicianJob.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      // ignore: avoid_print
      print('[TechnicianJobService] fetchAssignedJobs error: ${e.message}');
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('[TechnicianJobService] fetchAssignedJobs unexpected: $e');
      return [];
    }
  }

  /// Accepts a job: updates status to 'confirmed' and assigns partner.
  Future<bool> acceptJob(String bookingId, String partnerId) async {
    try {
      await _client
          .from('bookings')
          .update({'status': 'confirmed', 'partner_id': partnerId})
          .eq('id', bookingId);
      return true;
    } on PostgrestException catch (e) {
      // ignore: avoid_print
      print('[TechnicianJobService] acceptJob error: ${e.message}');
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[TechnicianJobService] acceptJob unexpected: $e');
      return false;
    }
  }

  /// Declines a job: updates status to 'declined'.
  Future<bool> declineJob(String bookingId) async {
    try {
      await _client
          .from('bookings')
          .update({'status': 'declined'})
          .eq('id', bookingId);
      return true;
    } on PostgrestException catch (e) {
      // ignore: avoid_print
      print('[TechnicianJobService] declineJob error: ${e.message}');
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[TechnicianJobService] declineJob unexpected: $e');
      return false;
    }
  }

  /// Marks an active job as completed.
  Future<bool> completeJob(String bookingId) async {
    try {
      await _client
          .from('bookings')
          .update({'status': 'completed'})
          .eq('id', bookingId);
      return true;
    } on PostgrestException catch (e) {
      // ignore: avoid_print
      print('[TechnicianJobService] completeJob error: ${e.message}');
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[TechnicianJobService] completeJob unexpected: $e');
      return false;
    }
  }

  /// Subscribes to real-time inserts on the bookings table (new jobs).
  RealtimeChannel subscribeToNewJobs(
    void Function(TechnicianJob job) onNewJob,
  ) {
    return _client
        .channel('public:bookings:pending')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            final record = payload.newRecord;
            if (record['status'] == 'pending') {
              onNewJob(TechnicianJob.fromJson(record));
            }
          },
        )
        .subscribe();
  }
}
