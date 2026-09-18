import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class EarningsTransaction {
  final String id;
  final String bookingRef;
  final String service;
  final String customerName;
  final String address;
  final int amount;
  final String paymentMethod;
  final int? customerRating;
  final String? invoiceNumber;
  final DateTime completedAt;

  EarningsTransaction({
    required this.id,
    required this.bookingRef,
    required this.service,
    required this.customerName,
    required this.address,
    required this.amount,
    required this.paymentMethod,
    this.customerRating,
    this.invoiceNumber,
    required this.completedAt,
  });

  factory EarningsTransaction.fromJson(Map<String, dynamic> json) {
    return EarningsTransaction(
      id: json['id']?.toString() ?? '',
      bookingRef: json['booking_ref']?.toString() ?? '',
      service: json['service']?.toString() ?? 'Home Service',
      customerName: json['customer_name']?.toString() ?? 'Customer',
      address: json['address']?.toString() ?? '',
      amount: (json['total_amount'] as num?)?.toInt() ?? 0,
      paymentMethod: json['payment_method']?.toString() ?? 'Online',
      customerRating: (json['customer_rating_given'] as num?)?.toInt(),
      invoiceNumber: json['invoice_number']?.toString(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class MonthlyEarning {
  final String month;
  final int amount;
  final int jobCount;

  MonthlyEarning({
    required this.month,
    required this.amount,
    required this.jobCount,
  });
}

class PartnerEarningsSummary {
  final int totalEarnings;
  final int completedJobs;
  final double averageRating;
  final int thisMonthEarnings;
  final List<MonthlyEarning> monthlyData;
  final List<EarningsTransaction> transactions;

  PartnerEarningsSummary({
    required this.totalEarnings,
    required this.completedJobs,
    required this.averageRating,
    required this.thisMonthEarnings,
    required this.monthlyData,
    required this.transactions,
  });
}

class PartnerEarningsService {
  static PartnerEarningsService? _instance;
  static PartnerEarningsService get instance =>
      _instance ??= PartnerEarningsService._();

  PartnerEarningsService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  Future<PartnerEarningsSummary> fetchEarningsSummary() async {
    try {
      // Fetch all completed bookings for this partner
      // We query broadly since partner_id can be UUID or user_id text
      final userId = _client.auth.currentUser?.id;

      List<dynamic> bookings = [];

      // Try by partner_user_id first (text match)
      if (userId != null) {
        final byUserId = await _client
            .from('bookings')
            .select(
              'id, booking_ref, service, customer_name, address, total_amount, payment_method, customer_rating_given, invoice_number, completed_at',
            )
            .eq('status', 'completed')
            .eq('partner_user_id', userId)
            .order('completed_at', ascending: false);
        bookings = byUserId;
      }

      // If no results, fall back to fetching all completed bookings (demo mode)
      if (bookings.isEmpty) {
        final allCompleted = await _client
            .from('bookings')
            .select(
              'id, booking_ref, service, customer_name, address, total_amount, payment_method, customer_rating_given, invoice_number, completed_at',
            )
            .eq('status', 'completed')
            .order('completed_at', ascending: false)
            .limit(50);
        bookings = allCompleted;
      }

      final transactions = bookings
          .map((b) => EarningsTransaction.fromJson(b as Map<String, dynamic>))
          .toList();

      // Compute totals
      final totalEarnings = transactions.fold<int>(
        0,
        (sum, t) => sum + t.amount,
      );
      final completedJobs = transactions.length;

      // Average rating from rated transactions
      final ratedTransactions = transactions
          .where((t) => t.customerRating != null)
          .toList();
      final averageRating = ratedTransactions.isEmpty
          ? 0.0
          : ratedTransactions.fold<double>(
                  0,
                  (sum, t) => sum + (t.customerRating ?? 0),
                ) /
                ratedTransactions.length;

      // This month earnings
      final now = DateTime.now();
      final thisMonthEarnings = transactions
          .where(
            (t) =>
                t.completedAt.year == now.year &&
                t.completedAt.month == now.month,
          )
          .fold<int>(0, (sum, t) => sum + t.amount);

      // Build monthly chart data (last 6 months)
      final monthlyData = _buildMonthlyData(transactions);

      // Fetch partner profile rating if available
      double profileRating = averageRating;
      try {
        final partnerProfile = await _client
            .from('partner_profiles')
            .select('rating')
            .maybeSingle();
        if (partnerProfile != null && partnerProfile['rating'] != null) {
          profileRating =
              (partnerProfile['rating'] as num?)?.toDouble() ?? averageRating;
        }
      } catch (_) {}

      return PartnerEarningsSummary(
        totalEarnings: totalEarnings,
        completedJobs: completedJobs,
        averageRating: ratedTransactions.isNotEmpty
            ? averageRating
            : profileRating,
        thisMonthEarnings: thisMonthEarnings,
        monthlyData: monthlyData,
        transactions: transactions,
      );
    } on PostgrestException catch (e) {
      // ignore: avoid_print
      print(
        '[PartnerEarningsService] fetchEarningsSummary error: ${e.message}',
      );
      return _emptyEarnings();
    } catch (e) {
      // ignore: avoid_print
      print('[PartnerEarningsService] fetchEarningsSummary unexpected: $e');
      return _emptyEarnings();
    }
  }

  List<MonthlyEarning> _buildMonthlyData(
    List<EarningsTransaction> transactions,
  ) {
    final now = DateTime.now();
    final months = <MonthlyEarning>[];
    final monthNames = [
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

    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final targetYear = targetDate.year;
      final targetMonth = targetDate.month;

      final monthTransactions = transactions.where(
        (t) =>
            t.completedAt.year == targetYear &&
            t.completedAt.month == targetMonth,
      );

      final amount = monthTransactions.fold<int>(0, (sum, t) => sum + t.amount);
      final count = monthTransactions.length;

      months.add(
        MonthlyEarning(
          month: monthNames[targetMonth - 1],
          amount: amount,
          jobCount: count,
        ),
      );
    }

    return months;
  }

  PartnerEarningsSummary _emptyEarnings() {
    return PartnerEarningsSummary(
      totalEarnings: 0,
      completedJobs: 0,
      averageRating: 0.0,
      thisMonthEarnings: 0,
      monthlyData: [],
      transactions: [],
    );
  }
}
