import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic>? orderData;

  const OrderConfirmationScreen({super.key, this.orderData});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _contentController;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentFade;

  late Map<String, dynamic> _order;

  @override
  void initState() {
    super.initState();
    _order =
        widget.orderData ??
        {
          'service': 'AC Repair & Service',
          'technician': 'Rajesh Kumar',
          'date': 'Today, 3:00 PM',
          'address': '42, Koramangala, Bengaluru',
          'paymentMethod': 'UPI',
          'totalAmount': 685,
          'bookingId': 'FIQ-DEMO1234',
          'paymentId': 'pay_DEMO123456',
          'status': 'confirmed',
        };

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    // Staggered animation
    _checkController.forward().then((_) {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = _order['bookingId'] as String? ?? 'FIQ-UNKNOWN';
    final paymentId = _order['paymentId'] as String? ?? '';
    final total = (_order['totalAmount'] as num?)?.toInt() ?? 0;
    final method = _order['paymentMethod'] as String? ?? 'UPI';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Animated check circle
                    ScaleTransition(
                      scale: _checkScale,
                      child: FadeTransition(
                        opacity: _checkOpacity,
                        child: _SuccessCircle(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: Column(
                          children: [
                            Text(
                              'Booking Confirmed!',
                              style: GoogleFonts.dmSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your technician has been notified\nand will arrive on time.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),
                            _BookingIdCard(bookingId: bookingId),
                            const SizedBox(height: 20),
                            _TechnicianStatusCard(order: _order),
                            const SizedBox(height: 20),
                            _PaymentReceiptCard(
                              paymentId: paymentId,
                              method: method,
                              total: total,
                              order: _order,
                            ),
                            const SizedBox(height: 20),
                            _NextStepsCard(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomActions(
              onTrack: () {
                context.go(AppRoutes.liveTrackingScreen);
              },
              onHome: () {
                context.go(AppRoutes.homeScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Success Circle ──────────────────────────────────────────────────────────

class _SuccessCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withAlpha(20),
          ),
        ),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withAlpha(40),
          ),
        ),
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
        ),
      ],
    );
  }
}

// ─── Booking ID Card ─────────────────────────────────────────────────────────

class _BookingIdCard extends StatelessWidget {
  final String bookingId;

  const _BookingIdCard({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.secondary, const Color(0xFF2D2D44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Booking ID',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.white.withAlpha(160),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bookingId,
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppTheme.primary.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: AppTheme.primary, size: 8),
                const SizedBox(width: 6),
                Text(
                  'Payment Successful',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
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

// ─── Technician Status Card ──────────────────────────────────────────────────

class _TechnicianStatusCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _TechnicianStatusCard({required this.order});

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
                const Icon(
                  Icons.engineering_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Technician Assignment',
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
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.pexels.com/photos/3785079/pexels-photo-3785079.jpeg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['technician'] as String? ?? 'Rajesh Kumar',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppTheme.warning,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '4.9 · 312 jobs',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '✓ Assigned',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _AssignmentTimeline(
              date: order['date'] as String? ?? 'Today',
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentTimeline extends StatelessWidget {
  final String date;

  const _AssignmentTimeline({required this.date});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Booking Confirmed', true),
      ('Technician Assigned', true),
      ('En Route to Location', false),
      ('Service Completed', false),
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isLast = i == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.$2 ? AppTheme.primary : AppTheme.outlineLight,
                    border: Border.all(
                      color: step.$2 ? AppTheme.primary : AppTheme.outlineLight,
                    ),
                  ),
                  child: step.$2
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    color: step.$2
                        ? AppTheme.primary.withAlpha(60)
                        : AppTheme.outlineLight,
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 8),
              child: Text(
                step.$1,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: step.$2 ? FontWeight.w600 : FontWeight.w400,
                  color: step.$2 ? AppTheme.secondary : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─── Payment Receipt Card ────────────────────────────────────────────────────

class _PaymentReceiptCard extends StatelessWidget {
  final String paymentId;
  final String method;
  final int total;
  final Map<String, dynamic> order;

  const _PaymentReceiptCard({
    required this.paymentId,
    required this.method,
    required this.total,
    required this.order,
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
                const Icon(
                  Icons.receipt_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Receipt',
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
            child: Column(
              children: [
                _ReceiptRow(
                  label: 'Payment ID',
                  value: paymentId.length > 16
                      ? '${paymentId.substring(0, 16)}...'
                      : paymentId,
                ),
                const SizedBox(height: 8),
                _ReceiptRow(label: 'Method', value: method),
                const SizedBox(height: 8),
                _ReceiptRow(
                  label: 'Service',
                  value: order['service'] as String? ?? '',
                ),
                const SizedBox(height: 8),
                _ReceiptRow(
                  label: 'Date',
                  value: order['date'] as String? ?? 'Today',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppTheme.outlineLight),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount Paid',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondary,
                      ),
                    ),
                    Text(
                      '₹$total',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.secondary,
          ),
        ),
      ],
    );
  }
}

// ─── Next Steps Card ─────────────────────────────────────────────────────────

class _NextStepsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.notifications_active_rounded,
        'You\'ll receive SMS & app notifications',
      ),
      (Icons.location_on_rounded, 'Track your technician in real-time'),
      (Icons.star_rounded, 'Rate your experience after service'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Next?',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(s.$1, color: AppTheme.primary, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.$2,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Actions ──────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final VoidCallback onTrack;
  final VoidCallback onHome;

  const _BottomActions({required this.onTrack, required this.onHome});

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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onHome,
              icon: const Icon(Icons.home_rounded, size: 18),
              label: const Text('Go Home'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.secondary,
                side: const BorderSide(
                  color: AppTheme.outlineLight,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onTrack,
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: const Text('Track Technician'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
