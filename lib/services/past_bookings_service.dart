import 'package:supabase_flutter/supabase_flutter.dart';

class PastBooking {
  final String id;
  final String bookingRef;
  final String service;
  final String? partnerName;
  final String? scheduledAt;
  final String status;
  final int totalAmount;
  final String? address;
  final String? description;
  final int? customerRatingGiven;
  final String? customerReview;
  final DateTime createdAt;

  PastBooking({
    required this.id,
    required this.bookingRef,
    required this.service,
    this.partnerName,
    this.scheduledAt,
    required this.status,
    required this.totalAmount,
    this.address,
    this.description,
    this.customerRatingGiven,
    this.customerReview,
    required this.createdAt,
  });

  factory PastBooking.fromJson(Map<String, dynamic> json) {
    return PastBooking(
      id: json['id']?.toString() ?? '',
      bookingRef: json['booking_ref']?.toString() ?? '',
      service: json['service']?.toString() ?? '',
      partnerName: json['partner_name']?.toString(),
      scheduledAt: json['scheduled_at']?.toString(),
      status: json['status']?.toString() ?? 'completed',
      totalAmount: (json['total_amount'] as num?)?.toInt() ?? 0,
      address: json['address']?.toString(),
      description: json['description']?.toString(),
      customerRatingGiven: (json['customer_rating_given'] as num?)?.toInt(),
      customerReview: json['customer_review']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class PastBookingsService {
  static final _client = Supabase.instance.client;

  /// Fetch completed bookings for the current user (or all demo bookings)
  static Future<List<PastBooking>> fetchPastBookings() async {
    try {
      final response = await _client
          .from('bookings')
          .select(
            'id, booking_ref, service, partner_name, scheduled_at, status, '
            'total_amount, address, description, customer_rating_given, '
            'customer_review, created_at',
          )
          .eq('status', 'completed')
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => PastBooking.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Submit a star rating (and optional review) for a booking
  static Future<bool> submitRating({
    required String bookingId,
    required int rating,
    String? review,
  }) async {
    try {
      await _client
          .from('bookings')
          .update({
            'customer_rating_given': rating,
            if (review != null && review.isNotEmpty) 'customer_review': review,
          })
          .eq('id', bookingId);
      return true;
    } catch (e) {
      return false;
    }
  }
}