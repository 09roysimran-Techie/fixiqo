import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

/// Result of a partner auto-assignment attempt.
class AssignedPartner {
  final String partnerId;
  final String partnerName;
  final double rating;
  final String? avatarUrl;
  final double? distanceKm;

  const AssignedPartner({
    required this.partnerId,
    required this.partnerName,
    required this.rating,
    this.avatarUrl,
    this.distanceKm,
  });
}

/// Handles real partner auto-selection by service specialty and location proximity.
///
/// Flow:
///   1. Call [findAndAssignPartner] with service name + optional customer coordinates.
///   2. The Postgres function `find_nearest_partner` runs a Haversine query and
///      returns the nearest available partner matching the specialty.
///   3. The selected partner is marked unavailable and a booking row is persisted.
///   4. Returns [AssignedPartner] with name, rating, and distance.
class JobAssignmentService {
  static JobAssignmentService? _instance;
  static JobAssignmentService get instance =>
      _instance ??= JobAssignmentService._();

  JobAssignmentService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Maps service display names to the specialty values stored in partner_profiles.
  static const Map<String, String> _serviceToSpecialty = {
    'AC Repair & Service': 'AC Repair',
    'AC Repair': 'AC Repair',
    'Plumbing': 'Plumbing',
    'Electrical': 'Electrical',
    'Electrical Repair': 'Electrical',
    'Carpentry': 'Carpentry',
    'Locksmith': 'Locksmith',
    'Pest Control': 'Plumbing', // fallback to closest category
    'Cleaning': 'Plumbing',
  };

  /// Finds the nearest available partner for [serviceName] and persists a booking.
  ///
  /// [customerLat] / [customerLng] are optional — when provided the Haversine
  /// distance is used; otherwise the highest-rated available partner is chosen.
  ///
  /// Returns null if no available partner is found.
  Future<AssignedPartner?> findAndAssignPartner({
    required String bookingRef,
    required String serviceName,
    String? customerId,
    String? address,
    String? scheduledAt,
    int totalAmount = 0,
    String? paymentId,
    String? paymentMethod,
    double? customerLat,
    double? customerLng,
  }) async {
    try {
      final specialty =
          _serviceToSpecialty[serviceName] ?? _guessSpecialty(serviceName);

      // Call the Postgres Haversine function
      final rows =
          await _client.rpc(
                'find_nearest_partner',
                params: {
                  'p_specialty': specialty,
                  if (customerLat != null) 'p_customer_lat': customerLat,
                  if (customerLng != null) 'p_customer_lng': customerLng,
                },
              )
              as List<dynamic>;

      if (rows.isEmpty) return null;

      final row = rows.first as Map<String, dynamic>;
      final partnerId = row['partner_id'] as String;
      final partnerName = row['partner_name'] as String? ?? 'Technician';
      final rating = (row['rating'] as num?)?.toDouble() ?? 4.5;
      final avatarUrl = row['avatar_url'] as String?;
      final distanceKm = (row['distance_km'] as num?)?.toDouble();

      // Mark partner as unavailable (atomic update)
      await _client
          .from('partner_profiles')
          .update({
            'is_available': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', partnerId);

      // Persist booking record
      await _client.from('bookings').insert({
        'booking_ref': bookingRef,
        'customer_id': customerId ?? 'guest',
        'partner_id': partnerId,
        'service': serviceName,
        'address': address,
        'customer_lat': customerLat,
        'customer_lng': customerLng,
        'scheduled_at': scheduledAt,
        'status': 'confirmed',
        'total_amount': totalAmount,
        'payment_id': paymentId,
        'payment_method': paymentMethod,
        'partner_name': partnerName,
      });

      return AssignedPartner(
        partnerId: partnerId,
        partnerName: partnerName,
        rating: rating,
        avatarUrl: avatarUrl,
        distanceKm: distanceKm,
      );
    } on PostgrestException catch (e) {
      // Log and return null so the caller can fall back gracefully
      // ignore: avoid_print
      print('[JobAssignmentService] Supabase error: ${e.message}');
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[JobAssignmentService] Unexpected error: $e');
      return null;
    }
  }

  /// Marks a partner as available again (call when job is completed/cancelled).
  Future<void> releasePartner(String partnerId) async {
    try {
      await _client
          .from('partner_profiles')
          .update({
            'is_available': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', partnerId);
    } catch (_) {}
  }

  /// Simple keyword-based specialty guesser for unmapped service names.
  String _guessSpecialty(String serviceName) {
    final lower = serviceName.toLowerCase();
    if (lower.contains('ac') || lower.contains('air')) return 'AC Repair';
    if (lower.contains('plumb') ||
        lower.contains('pipe') ||
        lower.contains('water')) {
      return 'Plumbing';
    }
    if (lower.contains('electric') ||
        lower.contains('wiring') ||
        lower.contains('power')) {
      return 'Electrical';
    }
    if (lower.contains('carp') ||
        lower.contains('wood') ||
        lower.contains('furniture')) {
      return 'Carpentry';
    }
    if (lower.contains('lock') ||
        lower.contains('key') ||
        lower.contains('door')) {
      return 'Locksmith';
    }
    // Default fallback
    return 'Plumbing';
  }
}
