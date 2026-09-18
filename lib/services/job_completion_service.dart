import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

/// Model representing a generated invoice/receipt.
class JobInvoice {
  final String id;
  final String invoiceNumber;
  final String bookingId;
  final String bookingRef;
  final String customerName;
  final String customerAddress;
  final String service;
  final String? serviceNotes;
  final String? partnerName;
  final int amount;
  final int taxAmount;
  final int totalAmount;
  final String? paymentMethod;
  final String status;
  final DateTime issuedAt;

  JobInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.bookingId,
    required this.bookingRef,
    required this.customerName,
    required this.customerAddress,
    required this.service,
    this.serviceNotes,
    this.partnerName,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    this.paymentMethod,
    required this.status,
    required this.issuedAt,
  });

  factory JobInvoice.fromJson(Map<String, dynamic> json) {
    return JobInvoice(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      bookingRef: json['booking_ref']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Customer',
      customerAddress: json['customer_address']?.toString() ?? '',
      service: json['service']?.toString() ?? 'Home Service',
      serviceNotes: json['service_notes']?.toString(),
      partnerName: json['partner_name']?.toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toInt() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toInt() ?? 0,
      paymentMethod: json['payment_method']?.toString(),
      status: json['status']?.toString() ?? 'issued',
      issuedAt: json['issued_at'] != null
          ? DateTime.tryParse(json['issued_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Service for completing jobs, saving service notes, and generating invoices.
class JobCompletionService {
  static JobCompletionService? _instance;
  static JobCompletionService get instance =>
      _instance ??= JobCompletionService._();

  JobCompletionService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Generates a unique invoice number.
  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final random = (now.millisecondsSinceEpoch % 10000).toString().padLeft(
      4,
      '0',
    );
    return 'INV-$timestamp-$random';
  }

  /// Marks a booking as complete with service notes and generates an invoice.
  /// Returns the generated [JobInvoice] on success, or null on failure.
  Future<JobInvoice?> completeJobWithInvoice({
    required String bookingId,
    required String bookingRef,
    required String customerName,
    required String customerAddress,
    required String service,
    required String serviceNotes,
    required String partnerName,
    required int totalAmount,
    String? paymentMethod,
  }) async {
    try {
      final invoiceNumber = _generateInvoiceNumber();
      final completedAt = DateTime.now().toIso8601String();

      // Calculate tax (18% GST)
      final baseAmount = (totalAmount / 1.18).round();
      final taxAmount = totalAmount - baseAmount;

      // 1. Update booking: mark completed, save service notes, invoice number
      await _client
          .from('bookings')
          .update({
            'status': 'completed',
            'service_notes': serviceNotes,
            'invoice_number': invoiceNumber,
            'completed_at': completedAt,
          })
          .eq('id', bookingId);

      // 2. Insert invoice record
      final invoiceData = {
        'invoice_number': invoiceNumber,
        'booking_id': bookingId,
        'booking_ref': bookingRef,
        'customer_name': customerName,
        'customer_address': customerAddress,
        'service': service,
        'service_notes': serviceNotes,
        'partner_name': partnerName,
        'amount': baseAmount,
        'tax_amount': taxAmount,
        'total_amount': totalAmount,
        'payment_method': paymentMethod ?? 'Online',
        'status': 'issued',
        'issued_at': completedAt,
      };

      final response = await _client
          .from('invoices')
          .insert(invoiceData)
          .select()
          .single();

      return JobInvoice.fromJson(response);
    } on PostgrestException catch (e) {
      // ignore: avoid_print
      print(
        '[JobCompletionService] completeJobWithInvoice error: ${e.message}',
      );
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[JobCompletionService] completeJobWithInvoice unexpected: $e');
      return null;
    }
  }

  /// Fetches an existing invoice by booking ID.
  Future<JobInvoice?> fetchInvoiceByBookingId(String bookingId) async {
    try {
      final response = await _client
          .from('invoices')
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (response == null) return null;
      return JobInvoice.fromJson(response);
    } on PostgrestException catch (e) {
      // ignore: avoid_print
      print('[JobCompletionService] fetchInvoice error: ${e.message}');
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[JobCompletionService] fetchInvoice unexpected: $e');
      return null;
    }
  }
}
