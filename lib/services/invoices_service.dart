import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class CustomerInvoice {
  final String id;
  final String invoiceNumber;
  final String bookingId;
  final String bookingRef;
  final String service;
  final String? serviceNotes;
  final String? partnerName;
  final int amount;
  final int taxAmount;
  final int totalAmount;
  final String? paymentMethod;
  final String status;
  final DateTime issuedAt;

  CustomerInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.bookingId,
    required this.bookingRef,
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

  factory CustomerInvoice.fromJson(Map<String, dynamic> json) {
    return CustomerInvoice(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      bookingRef: json['booking_ref']?.toString() ?? '',
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

  String get formattedDate {
    final months = [
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
    return '${issuedAt.day} ${months[issuedAt.month - 1]} ${issuedAt.year}';
  }

  String get formattedTotal =>
      '₹${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String get formattedAmount =>
      '₹${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String get formattedTax =>
      '₹${taxAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

class InvoicesService {
  static InvoicesService? _instance;
  static InvoicesService get instance => _instance ??= InvoicesService._();

  InvoicesService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  Future<List<CustomerInvoice>> fetchCustomerInvoices() async {
    try {
      final response = await _client
          .from('invoices')
          .select()
          .order('issued_at', ascending: false);

      return (response as List)
          .map((e) => CustomerInvoice.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      // ignore: avoid_print
      print('[InvoicesService] fetchCustomerInvoices error: ${e.message}');
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('[InvoicesService] fetchCustomerInvoices unexpected: $e');
      return [];
    }
  }
}
