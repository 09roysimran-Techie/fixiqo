import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const PaymentScreen({super.key, this.bookingData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  int _selectedMethod = 0; // 0=UPI, 1=Card, 2=Wallet
  bool _isProcessing = false;
  final _upiController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Booking details (from args or defaults)
  late Map<String, dynamic> _booking;

  @override
  void initState() {
    super.initState();
    _booking =
        widget.bookingData ??
        {
          'service': 'AC Repair & Service',
          'technician': 'Rajesh Kumar',
          'date': 'Today, 3:00 PM',
          'address': '42, Koramangala, Bengaluru',
          'basePrice': 599,
          'convenienceFee': 29,
          'gst': 57,
        };

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  int get _basePrice => (_booking['basePrice'] as num?)?.toInt() ?? 0;
  int get _platformFee => (_booking['convenienceFee'] as num?)?.toInt() ?? 0;
  int get _gst => (_booking['gst'] as num?)?.toInt() ?? 0;
  int get _totalAmount => _basePrice + _platformFee + _gst;

  void _proceedToPayment() {
    if (_isProcessing) return;
    _showPaymentConfirmationSheet();
  }

  void _showPaymentConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PaymentConfirmationSheet(
        booking: _booking,
        basePrice: _basePrice,
        platformFee: _platformFee,
        gst: _gst,
        total: _totalAmount,
        paymentMethodLabel: _selectedMethod == 0
            ? 'UPI'
            : _selectedMethod == 1
            ? 'Credit / Debit Card'
            : 'Mobile Wallet',
        onConfirm: () {
          Navigator.of(ctx).pop();
          _launchRazorpay();
        },
      ),
    );
  }

  void _launchRazorpay() {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      context.push(
        AppRoutes.bookingConfirmationScreen,
        extra: {
          ..._booking,
          'paymentMethod': _selectedMethod == 0
              ? 'UPI'
              : _selectedMethod == 1
              ? 'Card'
              : 'Wallet',
          'totalAmount': _totalAmount,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        title: Text(
          'Payment',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BookingSummaryCard(
                    booking: _booking,
                    basePrice: _basePrice,
                    platformFee: _platformFee,
                    gst: _gst,
                    total: _totalAmount,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Choose Payment Method',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PaymentMethodTile(
                    index: 0,
                    selected: _selectedMethod == 0,
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: const Color(0xFF6C63FF),
                    title: 'UPI',
                    subtitle: 'Pay via any UPI app',
                    onTap: () => setState(() => _selectedMethod = 0),
                    child: _selectedMethod == 0
                        ? _UpiInput(controller: _upiController)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _PaymentMethodTile(
                    index: 1,
                    selected: _selectedMethod == 1,
                    icon: Icons.credit_card_rounded,
                    iconColor: const Color(0xFFFF6B6B),
                    title: 'Credit / Debit Card',
                    subtitle: 'Visa, Mastercard, RuPay',
                    onTap: () => setState(() => _selectedMethod = 1),
                    child: _selectedMethod == 1
                        ? _CardInput(
                            numberController: _cardNumberController,
                            nameController: _cardNameController,
                            expiryController: _cardExpiryController,
                            cvvController: _cardCvvController,
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _PaymentMethodTile(
                    index: 2,
                    selected: _selectedMethod == 2,
                    icon: Icons.phone_android_rounded,
                    iconColor: const Color(0xFF00C896),
                    title: 'Mobile Wallet',
                    subtitle: 'Paytm, PhonePe, Amazon Pay',
                    onTap: () => setState(() => _selectedMethod = 2),
                  ),
                  const SizedBox(height: 16),
                  _SecurePaymentBadge(),
                ],
              ),
            ),
          ),
          _PayButton(
            total: _totalAmount,
            isProcessing: _isProcessing,
            onTap: _proceedToPayment,
            pulseAnim: _pulseAnim,
          ),
        ],
      ),
    );
  }
}

// ─── Booking Summary Card (Enhanced) ─────────────────────────────────────────

class _BookingSummaryCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final int basePrice;
  final int platformFee;
  final int gst;
  final int total;

  const _BookingSummaryCard({
    required this.booking,
    required this.basePrice,
    required this.platformFee,
    required this.gst,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Order Summary',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Razorpay Secured',
                    style: GoogleFonts.dmSans(
                      color: AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Service info rows
                _SummaryRow(
                  icon: Icons.build_circle_outlined,
                  label: booking['service'] as String? ?? 'Service',
                  value: '',
                  isBold: true,
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Technician',
                  value: booking['technician'] as String? ?? 'Assigned',
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  icon: Icons.schedule_rounded,
                  label: 'Scheduled',
                  value: booking['date'] as String? ?? 'Today',
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: booking['address'] as String? ?? '',
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: AppTheme.outlineLight),
                ),

                // ── Price Breakdown Section ──
                Row(
                  children: [
                    const Icon(
                      Icons.calculate_outlined,
                      size: 15,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Price Breakdown',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Service Cost
                _ItemizedRow(
                  label: 'Service Cost',
                  sublabel: 'Labour + parts estimate',
                  amount: basePrice,
                  amountColor: AppTheme.secondary,
                ),
                const SizedBox(height: 10),

                // Platform Fee
                _ItemizedRow(
                  label: 'Platform Fee',
                  sublabel: 'Booking & support charges',
                  amount: platformFee,
                  amountColor: AppTheme.secondary,
                  badge: 'One-time',
                  badgeColor: const Color(0xFF6C63FF),
                ),
                const SizedBox(height: 10),

                // GST
                _ItemizedRow(
                  label: 'GST',
                  sublabel: '18% on service cost',
                  amount: gst,
                  amountColor: AppTheme.secondary,
                  badge: '18%',
                  badgeColor: const Color(0xFFFF8C42),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AppTheme.outlineLight, thickness: 1.5),
                ),

                // Total
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Payable',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.secondary,
                            ),
                          ),
                          Text(
                            'Inclusive of all taxes',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹$total',
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Itemized Row ─────────────────────────────────────────────────────────────

class _ItemizedRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final int amount;
  final Color amountColor;
  final String? badge;
  final Color? badgeColor;

  const _ItemizedRow({
    required this.label,
    required this.sublabel,
    required this.amount,
    required this.amountColor,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondary,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? AppTheme.primary).withAlpha(20),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        badge!,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeColor ?? AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        Text(
          '₹$amount',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

// ─── Payment Confirmation Bottom Sheet ───────────────────────────────────────

class _PaymentConfirmationSheet extends StatelessWidget {
  final Map<String, dynamic> booking;
  final int basePrice;
  final int platformFee;
  final int gst;
  final int total;
  final String paymentMethodLabel;
  final VoidCallback onConfirm;

  const _PaymentConfirmationSheet({
    required this.booking,
    required this.basePrice,
    required this.platformFee,
    required this.gst,
    required this.total,
    required this.paymentMethodLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          // Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Payment',
                    style: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondary,
                    ),
                  ),
                  Text(
                    'Review before proceeding to Razorpay',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Breakdown container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outlineLight),
            ),
            child: Column(
              children: [
                _SheetRow(
                  label: 'Service',
                  value: booking['service'] as String? ?? 'Home Service',
                  isService: true,
                ),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                _SheetPriceRow(
                  label: 'Service Cost',
                  sublabel: 'Labour + parts',
                  amount: basePrice,
                ),
                const SizedBox(height: 10),
                _SheetPriceRow(
                  label: 'Platform Fee',
                  sublabel: 'Booking & support',
                  amount: platformFee,
                ),
                const SizedBox(height: 10),
                _SheetPriceRow(
                  label: 'GST (18%)',
                  sublabel: 'Govt. tax on service',
                  amount: gst,
                ),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Payable',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondary,
                      ),
                    ),
                    Text(
                      '₹$total',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Payment method indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payment_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  'Paying via  ',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  paymentMethodLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.lock_rounded,
                  size: 14,
                  color: AppTheme.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'Secured',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Proceed to Pay  ₹$total',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'You will be redirected to Razorpay\'s secure checkout',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isService;

  const _SheetRow({
    required this.label,
    required this.value,
    this.isService = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: isService ? FontWeight.w700 : FontWeight.w500,
              color: AppTheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetPriceRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final int amount;

  const _SheetPriceRow({
    required this.label,
    required this.sublabel,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondary,
                ),
              ),
              Text(
                sublabel,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        Text(
          '₹$amount',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary,
          ),
        ),
      ],
    );
  }
}

// ─── Summary Row ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: isBold
              ? Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
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
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ─── Payment Method Tile ─────────────────────────────────────────────────────

class _PaymentMethodTile extends StatelessWidget {
  final int index;
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? child;

  const _PaymentMethodTile({
    required this.index,
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? AppTheme.primary.withAlpha(15)
            : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.outlineLight,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.outlineLight,
                        width: 2,
                      ),
                      color: selected ? AppTheme.primary : Colors.transparent,
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                ],
              ),
              if (child != null) ...[const SizedBox(height: 14), child!],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── UPI Input ───────────────────────────────────────────────────────────────

class _UpiInput extends StatelessWidget {
  final TextEditingController controller;

  const _UpiInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter UPI ID (e.g. name@upi)',
            hintStyle: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: const Icon(
              Icons.alternate_email_rounded,
              color: AppTheme.primary,
              size: 20,
            ),
            filled: true,
            fillColor: AppTheme.surfaceVariantLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.outlineLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.outlineLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _UpiAppChip(label: 'GPay', color: const Color(0xFF4285F4)),
            _UpiAppChip(label: 'PhonePe', color: const Color(0xFF5F259F)),
            _UpiAppChip(label: 'Paytm', color: const Color(0xFF00BAF2)),
            _UpiAppChip(label: 'BHIM', color: const Color(0xFF00A859)),
          ],
        ),
      ],
    );
  }
}

class _UpiAppChip extends StatelessWidget {
  final String label;
  final Color color;

  const _UpiAppChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Card Input ──────────────────────────────────────────────────────────────

class _CardInput extends StatelessWidget {
  final TextEditingController numberController;
  final TextEditingController nameController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  const _CardInput({
    required this.numberController,
    required this.nameController,
    required this.expiryController,
    required this.cvvController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CardField(
          controller: numberController,
          hint: 'Card Number',
          icon: Icons.credit_card_rounded,
          inputType: TextInputType.number,
          maxLength: 19,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
        ),
        const SizedBox(height: 10),
        _CardField(
          controller: nameController,
          hint: 'Cardholder Name',
          icon: Icons.person_outline_rounded,
          inputType: TextInputType.name,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _CardField(
                controller: expiryController,
                hint: 'MM/YY',
                icon: Icons.calendar_today_rounded,
                inputType: TextInputType.number,
                maxLength: 5,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ExpiryFormatter(),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CardField(
                controller: cvvController,
                hint: 'CVV',
                icon: Icons.lock_outline_rounded,
                inputType: TextInputType.number,
                maxLength: 3,
                obscure: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType inputType;
  final int? maxLength;
  final bool obscure;
  final List<TextInputFormatter>? inputFormatters;

  const _CardField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.inputType,
    this.maxLength,
    this.obscure = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscure,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 13,
          color: const Color(0xFF94A3B8),
        ),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 18),
        filled: true,
        fillColor: AppTheme.surfaceVariantLight,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.outlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length >= 3) {
      final formatted = '${text.substring(0, 2)}/${text.substring(2)}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return newValue;
  }
}

// ─── Secure Badge ────────────────────────────────────────────────────────────

class _SecurePaymentBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.success.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.success.withAlpha(50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: AppTheme.success,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '256-bit SSL encrypted · Powered by Razorpay',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppTheme.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pay Button ──────────────────────────────────────────────────────────────

class _PayButton extends StatelessWidget {
  final int total;
  final bool isProcessing;
  final VoidCallback onTap;
  final Animation<double> pulseAnim;

  const _PayButton({
    required this.total,
    required this.isProcessing,
    required this.onTap,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ScaleTransition(
        scale: pulseAnim,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isProcessing ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Review & Pay  ₹$total',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
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
}
