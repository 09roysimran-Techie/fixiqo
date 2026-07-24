import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

// Razorpay is NOT web-compatible — conditional import
import 'razorpay_stub.dart' if (dart.library.io) 'razorpay_real.dart' as rzp;

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic>? paymentData;

  const BookingConfirmationScreen({super.key, this.paymentData});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  bool _isLaunching = false;
  late Map<String, dynamic> _data;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _data =
        widget.paymentData ??
        {
          'service': 'AC Repair & Service',
          'technician': 'Rajesh Kumar',
          'date': 'Today, 3:00 PM',
          'address': '42, Koramangala, Bengaluru',
          'basePrice': 599,
          'convenienceFee': 29,
          'gst': 57,
          'paymentMethod': 'UPI',
          'totalAmount': 685,
        };

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  String _generateBookingId() {
    final rand = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return 'FIQ-${List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join()}';
  }

  void _launchRazorpay() {
    if (_isLaunching) return;
    setState(() => _isLaunching = true);

    final bookingId = _generateBookingId();
    final total = (_data['totalAmount'] as num?)?.toInt() ?? 685;

    if (kIsWeb) {
      // Web: simulate payment success
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() => _isLaunching = false);
        context.push(
          AppRoutes.orderConfirmationScreen,
          extra: {
            ..._data,
            'bookingId': bookingId,
            'paymentId': 'WEB_SIM_${DateTime.now().millisecondsSinceEpoch}',
            'status': 'confirmed',
          },
        );
      });
    } else {
      // Mobile: use Razorpay SDK via platform-specific file
      rzp.openRazorpay(
        amount: total * 100, // paise
        bookingId: bookingId,
        description: _data['service'] as String? ?? 'Home Service',
        onSuccess: (paymentId) {
          if (!mounted) return;
          setState(() => _isLaunching = false);
          context.push(
            AppRoutes.orderConfirmationScreen,
            extra: {
              ..._data,
              'bookingId': bookingId,
              'paymentId': paymentId,
              'status': 'confirmed',
            },
          );
        },
        onFailure: (code, description) {
          if (!mounted) return;
          setState(() => _isLaunching = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $description'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onWalletCreated: (_) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = (_data['totalAmount'] as num?)?.toInt() ?? 685;
    final method = _data['paymentMethod'] as String? ?? 'UPI';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        title: Text(
          'Confirm Booking',
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
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ConfirmationHeader(),
                    const SizedBox(height: 20),
                    _DetailSection(
                      title: 'Service Details',
                      icon: Icons.home_repair_service_rounded,
                      children: [
                        _DetailRow(
                          label: 'Service',
                          value: _data['service'] as String? ?? '',
                        ),
                        _DetailRow(
                          label: 'Technician',
                          value: _data['technician'] as String? ?? 'Assigned',
                        ),
                        _DetailRow(
                          label: 'Date & Time',
                          value: _data['date'] as String? ?? 'Today',
                        ),
                        _DetailRow(
                          label: 'Location',
                          value: _data['address'] as String? ?? '',
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _DetailSection(
                      title: 'Payment Details',
                      icon: Icons.payments_rounded,
                      children: [
                        _DetailRow(
                          label: 'Method',
                          value: method,
                          valueColor: AppTheme.primary,
                        ),
                        _DetailRow(
                          label: 'Service Charge',
                          value:
                              '₹${(_data['basePrice'] as num?)?.toInt() ?? 0}',
                        ),
                        _DetailRow(
                          label: 'Convenience Fee',
                          value:
                              '₹${(_data['convenienceFee'] as num?)?.toInt() ?? 0}',
                        ),
                        _DetailRow(
                          label: 'GST (18%)',
                          value: '₹${(_data['gst'] as num?)?.toInt() ?? 0}',
                        ),
                        _DetailRow(
                          label: 'Total',
                          value: '₹$total',
                          isBold: true,
                          valueColor: AppTheme.primary,
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _CancellationPolicy(),
                    const SizedBox(height: 8),
                    if (kIsWeb) _WebSimulationNote(),
                  ],
                ),
              ),
            ),
          ),
          _ConfirmPayButton(
            total: total,
            isLaunching: _isLaunching,
            onTap: _launchRazorpay,
          ),
        ],
      ),
    );
  }
}

// ─── Confirmation Header ─────────────────────────────────────────────────────

class _ConfirmationHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.secondary, const Color(0xFF2D2D44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppTheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Almost There!',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review your booking and confirm payment to get your technician assigned.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.white.withAlpha(180),
                    height: 1.4,
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

// ─── Detail Section ──────────────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.outlineLight),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? AppTheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cancellation Policy ─────────────────────────────────────────────────────

class _CancellationPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warning.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.warning,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Free cancellation up to 1 hour before the appointment. Late cancellations may incur a ₹50 fee.',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF92400E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSimulationNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.info.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.web_rounded, color: AppTheme.info, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Web preview: Payment will be simulated. Download the APK to test real Razorpay checkout.',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppTheme.info,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confirm Pay Button ──────────────────────────────────────────────────────

class _ConfirmPayButton extends StatelessWidget {
  final int total;
  final bool isLaunching;
  final VoidCallback onTap;

  const _ConfirmPayButton({
    required this.total,
    required this.isLaunching,
    required this.onTap,
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
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLaunching ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: isLaunching
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Launching Razorpay...',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Confirm & Pay ₹$total',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
