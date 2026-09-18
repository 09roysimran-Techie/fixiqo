import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/invoices_service.dart';
import '../../theme/app_theme.dart';

class InvoicesReceiptsScreen extends StatefulWidget {
  const InvoicesReceiptsScreen({super.key});

  @override
  State<InvoicesReceiptsScreen> createState() => _InvoicesReceiptsScreenState();
}

class _InvoicesReceiptsScreenState extends State<InvoicesReceiptsScreen>
    with SingleTickerProviderStateMixin {
  List<CustomerInvoice> _invoices = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _loadInvoices();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final invoices = await InvoicesService.instance.fetchCustomerInvoices();
      if (mounted) {
        setState(() {
          _invoices = invoices;
          _isLoading = false;
        });
        _fadeController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load invoices. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _showInvoiceDetail(CustomerInvoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InvoiceDetailSheet(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.secondary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Invoices & Receipts',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.secondary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.outlineLight),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _error != null
          ? _buildError()
          : _invoices.isEmpty
          ? _buildEmpty()
          : FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: _loadInvoices,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _invoices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _InvoiceCard(
                    invoice: _invoices[i],
                    onTap: () => _showInvoiceDetail(_invoices[i]),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loadInvoices,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppTheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Invoices Yet',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your invoices and receipts will appear here once a job is completed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Invoice List Card ────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  final CustomerInvoice invoice;
  final VoidCallback onTap;

  const _InvoiceCard({required this.invoice, required this.onTap});

  Color get _serviceColor {
    final s = invoice.service.toLowerCase();
    if (s.contains('electric')) return const Color(0xFFFFB347);
    if (s.contains('plumb')) return const Color(0xFF3B82F6);
    if (s.contains('ac') || s.contains('air')) return const Color(0xFF00C8FF);
    if (s.contains('carpen') || s.contains('wood')) {
      return const Color(0xFFFF6B35);
    }
    if (s.contains('paint')) return const Color(0xFF8B5CF6);
    if (s.contains('clean')) return const Color(0xFF10B981);
    return AppTheme.primary;
  }

  IconData get _serviceIcon {
    final s = invoice.service.toLowerCase();
    if (s.contains('electric')) return Icons.electrical_services_rounded;
    if (s.contains('plumb')) return Icons.plumbing_rounded;
    if (s.contains('ac') || s.contains('air')) return Icons.ac_unit_rounded;
    if (s.contains('carpen') || s.contains('wood')) {
      return Icons.handyman_rounded;
    }
    if (s.contains('paint')) return Icons.format_paint_rounded;
    if (s.contains('clean')) return Icons.cleaning_services_rounded;
    return Icons.build_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Service icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _serviceColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_serviceIcon, color: _serviceColor, size: 24),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.service,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  if (invoice.partnerName != null)
                    Text(
                      invoice.partnerName!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          invoice.invoiceNumber,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDark,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        invoice.formattedDate,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Amount + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  invoice.formattedTotal,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.secondary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(20),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Paid',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Invoice Detail Bottom Sheet ──────────────────────────────────────────────

class _InvoiceDetailSheet extends StatelessWidget {
  final CustomerInvoice invoice;

  const _InvoiceDetailSheet({required this.invoice});

  Color get _serviceColor {
    final s = invoice.service.toLowerCase();
    if (s.contains('electric')) return const Color(0xFFFFB347);
    if (s.contains('plumb')) return const Color(0xFF3B82F6);
    if (s.contains('ac') || s.contains('air')) return const Color(0xFF00C8FF);
    if (s.contains('carpen') || s.contains('wood')) {
      return const Color(0xFFFF6B35);
    }
    if (s.contains('paint')) return const Color(0xFF8B5CF6);
    if (s.contains('clean')) return const Color(0xFF10B981);
    return AppTheme.primary;
  }

  void _copyInvoiceNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: invoice.invoiceNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice number copied', style: GoogleFonts.dmSans()),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareInvoice(BuildContext context) {
    final text =
        '''
FIXIQO — Invoice Receipt
━━━━━━━━━━━━━━━━━━━━━━━━
Invoice No: ${invoice.invoiceNumber}
Date: ${invoice.formattedDate}
Service: ${invoice.service}
${invoice.partnerName != null ? 'Technician: ${invoice.partnerName}' : ''}
${invoice.serviceNotes != null ? 'Notes: ${invoice.serviceNotes}' : ''}
━━━━━━━━━━━━━━━━━━━━━━━━
Base Amount: ${invoice.formattedAmount}
GST (18%): ${invoice.formattedTax}
Total Paid: ${invoice.formattedTotal}
Payment: ${invoice.paymentMethod ?? 'Online'}
━━━━━━━━━━━━━━━━━━━━━━━━
Status: PAID ✓
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invoice details copied to clipboard',
          style: GoogleFonts.dmSans(),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outlineLight,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      'Invoice Details',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.outlineVariantLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: AppTheme.outlineLight),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Receipt header card
                      _buildReceiptHeader(),
                      const SizedBox(height: 20),
                      // Service details
                      _buildSection(
                        'Service Details',
                        Icons.build_circle_outlined,
                        [
                          _buildRow('Service', invoice.service),
                          if (invoice.partnerName != null)
                            _buildRow('Technician', invoice.partnerName!),
                          _buildRow('Date', invoice.formattedDate),
                          if (invoice.serviceNotes != null &&
                              invoice.serviceNotes!.isNotEmpty)
                            _buildRow(
                              'Notes',
                              invoice.serviceNotes!,
                              multiLine: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Payment breakdown
                      _buildPaymentBreakdown(),
                      const SizedBox(height: 16),
                      // Payment info
                      _buildSection('Payment Info', Icons.payment_rounded, [
                        _buildRow('Method', invoice.paymentMethod ?? 'Online'),
                        _buildRow('Status', 'Paid'),
                        _buildRow('Booking Ref', invoice.bookingRef),
                      ]),
                      const SizedBox(height: 24),
                      // Action buttons
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_serviceColor.withAlpha(25), _serviceColor.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _serviceColor.withAlpha(40), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _serviceColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: _serviceColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FIXIQO',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Invoice Receipt',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(20),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color(0xFF10B981).withAlpha(50),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'PAID',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: _serviceColor.withAlpha(30)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice No.',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    invoice.invoiceNumber,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    invoice.formattedTotal,
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.secondary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppTheme.outlineVariantLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: multiLine
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondary,
                    height: 1.5,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: label == 'Status'
                          ? const Color(0xFF10B981)
                          : AppTheme.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPaymentBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_outlined,
                  size: 16,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Amount Breakdown',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppTheme.outlineVariantLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              children: [
                _buildAmountRow(
                  'Service Charge',
                  invoice.formattedAmount,
                  isSubtle: true,
                ),
                const SizedBox(height: 10),
                _buildGstRow(),
                const SizedBox(height: 12),
                Container(height: 1, color: AppTheme.outlineLight),
                const SizedBox(height: 12),
                _buildAmountRow(
                  'Total Paid',
                  invoice.formattedTotal,
                  isBold: true,
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    String value, {
    bool isBold = false,
    bool isSubtle = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isSubtle
                ? const Color(0xFF64748B)
                : isBold
                ? AppTheme.secondary
                : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppTheme.secondary : const Color(0xFF475569),
            letterSpacing: isBold ? -0.3 : 0,
          ),
        ),
      ],
    );
  }

  Widget _buildGstRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'GST',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withAlpha(15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '18%',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),
        Text(
          invoice.formattedTax,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _copyInvoiceNumber(context),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text(
              'Copy No.',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.secondary,
              side: const BorderSide(color: AppTheme.outlineLight),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: () => _shareInvoice(context),
            icon: const Icon(Icons.share_rounded, size: 16),
            label: Text(
              'Share Receipt',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
