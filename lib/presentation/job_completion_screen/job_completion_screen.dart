import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/job_completion_service.dart';

class JobCompletionScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobCompletionScreen({super.key, required this.job});

  @override
  State<JobCompletionScreen> createState() => _JobCompletionScreenState();
}

class _JobCompletionScreenState extends State<JobCompletionScreen>
    with SingleTickerProviderStateMixin {
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  bool _isCompleted = false;
  JobInvoice? _generatedInvoice;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _job => widget.job;

  String get _bookingId => _job['id']?.toString() ?? '';
  String get _bookingRef =>
      _job['bookingRef']?.toString() ?? _job['booking_ref']?.toString() ?? '';
  String get _customerName =>
      _job['customerName']?.toString() ??
      _job['customer_name']?.toString() ??
      'Customer';
  String get _address => _job['address']?.toString() ?? '';
  String get _service => _job['service']?.toString() ?? 'Home Service';
  String get _partnerName => _job['partnerName']?.toString() ?? 'Technician';
  int get _totalAmount =>
      (_job['price'] as num?)?.toInt() ??
      (_job['total_amount'] as num?)?.toInt() ??
      0;
  String get _paymentMethod => _job['paymentMethod']?.toString() ?? 'Online';

  Future<void> _submitCompletion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final invoice = await JobCompletionService.instance.completeJobWithInvoice(
      bookingId: _bookingId,
      bookingRef: _bookingRef,
      customerName: _customerName,
      customerAddress: _address,
      service: _service,
      serviceNotes: _notesController.text.trim(),
      partnerName: _partnerName,
      totalAmount: _totalAmount,
      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isCompleted = true;
      _generatedInvoice = invoice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isCompleted
                    ? _buildInvoiceView(bottomPadding)
                    : _buildCompletionForm(bottomPadding),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isCompleted
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                border: const Border(
                  top: BorderSide(color: AppTheme.outlineLight),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCompletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    disabledBackgroundColor: AppTheme.primary.withAlpha(100),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Mark Complete & Generate Invoice',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppTheme.secondary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCompleted ? 'Job Completed' : 'Complete Job',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _isCompleted
                          ? 'Invoice generated successfully'
                          : 'Add service notes & generate invoice',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.white.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withAlpha(30),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppTheme.success.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.success,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Done',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Completion form ────────────────────────────────────────────────

  Widget _buildCompletionForm(double bottomPadding) {
    final baseAmount = _totalAmount > 0 ? (_totalAmount / 1.18).round() : 0;
    final taxAmount = _totalAmount - baseAmount;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 100 + bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job summary card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Icon(
                          _serviceIcon(_service),
                          color: AppTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _service,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.secondary,
                              ),
                            ),
                            Text(
                              _customerName,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹$_totalAmount',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.outlineLight),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.location_on_rounded, _address),
                  if (_bookingRef.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      Icons.receipt_long_rounded,
                      'Ref: $_bookingRef',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Service notes
            Text(
              'Service Notes',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Describe the work performed, parts used, and any recommendations',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesController,
              maxLines: 5,
              minLines: 4,
              textInputAction: TextInputAction.newline,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppTheme.secondary,
              ),
              decoration: InputDecoration(
                hintText:
                    'e.g. Replaced faulty pipe joint under kitchen sink. Applied sealant tape on joints. Tested for leaks — all clear.',
                hintStyle: GoogleFonts.manrope(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: const BorderSide(color: AppTheme.outlineLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: const BorderSide(color: AppTheme.outlineLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: const BorderSide(color: AppTheme.error),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please add service notes before completing the job';
                }
                if (value.trim().length < 10) {
                  return 'Notes must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Invoice preview
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Invoice Preview',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withAlpha(20),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppTheme.warning.withAlpha(60),
                          ),
                        ),
                        child: Text(
                          'Auto-generated',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.outlineLight),
                  const SizedBox(height: 10),
                  _buildLineRow('Service', _service),
                  _buildLineRow('Customer', _customerName),
                  _buildLineRow('Technician', _partnerName),
                  const SizedBox(height: 8),
                  const Divider(color: AppTheme.outlineLight),
                  const SizedBox(height: 8),
                  _buildLineRow('Base Amount', '₹$baseAmount'),
                  _buildLineRow('GST (18%)', '₹$taxAmount'),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                        ),
                      ),
                      Text(
                        '₹$_totalAmount',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.info.withAlpha(12),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppTheme.info.withAlpha(40)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.info,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The invoice will be automatically sent to the customer for confirmation once you mark the job complete.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppTheme.info,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Invoice view ───────────────────────────────────────────────────

  Widget _buildInvoiceView(double bottomPadding) {
    final invoice = _generatedInvoice;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 40 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.success, AppTheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Job Completed!',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Invoice sent to customer for confirmation',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: Colors.white.withAlpha(200),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Invoice card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INVOICE',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            invoice?.invoiceNumber ?? 'INV-PENDING',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.secondary,
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
                        color: AppTheme.success.withAlpha(20),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppTheme.success.withAlpha(60),
                        ),
                      ),
                      child: Text(
                        'ISSUED',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(invoice?.issuedAt ?? DateTime.now()),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: AppTheme.outlineLight),
                const SizedBox(height: 12),

                // Bill to
                Text(
                  'BILL TO',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invoice?.customerName ?? _customerName,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                  ),
                ),
                Text(
                  invoice?.customerAddress ?? _address,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                const Divider(color: AppTheme.outlineLight),
                const SizedBox(height: 12),

                // Service line item
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice?.service ?? _service,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            invoice?.serviceNotes ?? _notesController.text,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '₹${invoice?.amount ?? 0}',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppTheme.outlineLight),
                const SizedBox(height: 10),

                // Totals
                _buildLineRow('Subtotal', '₹${invoice?.amount ?? 0}'),
                const SizedBox(height: 4),
                _buildLineRow('GST (18%)', '₹${invoice?.taxAmount ?? 0}'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                        ),
                      ),
                      Text(
                        '₹${invoice?.totalAmount ?? _totalAmount}',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: AppTheme.outlineLight),
                const SizedBox(height: 10),

                _buildLineRow(
                  'Technician',
                  invoice?.partnerName ?? _partnerName,
                ),
                const SizedBox(height: 4),
                _buildLineRow(
                  'Payment',
                  invoice?.paymentMethod ?? _paymentMethod,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Back button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                'Back to Job Queue',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.outlineLight),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLineRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary,
          ),
        ),
      ],
    );
  }

  IconData _serviceIcon(String service) {
    switch (service) {
      case 'Plumbing':
        return Icons.plumbing_rounded;
      case 'AC Repair':
        return Icons.ac_unit_rounded;
      case 'Electrical':
        return Icons.electrical_services_rounded;
      case 'Locksmith':
        return Icons.lock_rounded;
      case 'Carpentry':
        return Icons.carpenter_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
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
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$min $ampm';
  }
}
