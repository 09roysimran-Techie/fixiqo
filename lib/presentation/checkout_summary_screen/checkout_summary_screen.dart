import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class CheckoutSummaryScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const CheckoutSummaryScreen({super.key, this.bookingData});

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;

  late Map<String, dynamic> _booking;

  @override
  void initState() {
    super.initState();
    _booking =
        widget.bookingData ??
        {
          'service': 'AC Repair & Service',
          'technician': 'Rajesh Kumar',
          'technicianRating': 4.8,
          'technicianJobs': 312,
          'date': 'Today, 3:00 PM',
          'address': '42, Koramangala, Bengaluru',
          'basePrice': 599,
          'convenienceFee': 29,
          'gst': 108,
        };

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnims = List.generate(
      5,
      (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(i * 0.12, 0.5 + i * 0.1, curve: Curves.easeOut),
        ),
      ),
    );

    _slideAnims = List.generate(
      5,
      (i) => Tween<Offset>(begin: Offset(0, 0.06 + i * 0.02), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _animController,
              curve: Interval(
                i * 0.12,
                0.5 + i * 0.1,
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int get _basePrice => (_booking['basePrice'] as num?)?.toInt() ?? 0;
  int get _convenienceFee => (_booking['convenienceFee'] as num?)?.toInt() ?? 0;
  int get _gst => (_booking['gst'] as num?)?.toInt() ?? 0;
  int get _total => _basePrice + _convenienceFee + _gst;

  void _proceedToPayment() {
    context.push(
      AppRoutes.paymentScreen,
      extra: {
        ..._booking,
        'basePrice': _basePrice,
        'convenienceFee': _convenienceFee,
        'gst': _gst,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order Summary',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepIndicator(currentStep: 2, totalSteps: 3),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Details Card
                  _AnimatedSection(
                    fadeAnim: _fadeAnims[0],
                    slideAnim: _slideAnims[0],
                    child: _ServiceDetailsCard(booking: _booking),
                  ),
                  const SizedBox(height: 16),

                  // Technician Card
                  _AnimatedSection(
                    fadeAnim: _fadeAnims[1],
                    slideAnim: _slideAnims[1],
                    child: _TechnicianCard(booking: _booking),
                  ),
                  const SizedBox(height: 16),

                  // Date & Time + Location Row
                  _AnimatedSection(
                    fadeAnim: _fadeAnims[2],
                    slideAnim: _slideAnims[2],
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.calendar_today_rounded,
                            iconColor: const Color(0xFF6C63FF),
                            label: 'Date & Time',
                            value: _booking['date']?.toString() ?? '—',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.location_on_rounded,
                            iconColor: AppTheme.primary,
                            label: 'Location',
                            value: _booking['address']?.toString() ?? '—',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Issue Description (if present)
                  if ((_booking['issueDescription'] as String?)?.isNotEmpty ==
                      true) ...[
                    _AnimatedSection(
                      fadeAnim: _fadeAnims[3],
                      slideAnim: _slideAnims[3],
                      child: _IssueCard(
                        description: _booking['issueDescription'] as String,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Price Breakdown
                  _AnimatedSection(
                    fadeAnim: _fadeAnims[4],
                    slideAnim: _slideAnims[4],
                    child: _PriceBreakdownCard(
                      basePrice: _basePrice,
                      convenienceFee: _convenienceFee,
                      gst: _gst,
                      total: _total,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancellation Policy
                  _AnimatedSection(
                    fadeAnim: _fadeAnims[4],
                    slideAnim: _slideAnims[4],
                    child: _CancellationPolicyNote(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Bottom CTA
          _BottomCta(total: _total, onTap: _proceedToPayment),
        ],
      ),
    );
  }
}

// ─── Animated Section Wrapper ─────────────────────────────────────────────────

class _AnimatedSection extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final Widget child;

  const _AnimatedSection({
    required this.fadeAnim,
    required this.slideAnim,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(position: slideAnim, child: child),
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final active = i < currentStep;
          final current = i == currentStep - 1;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.primary
                    : current
                    ? AppTheme.primary.withAlpha(180)
                    : Colors.white.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Service Details Card ─────────────────────────────────────────────────────

class _ServiceDetailsCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _ServiceDetailsCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = booking['service']?.toString() ?? 'Home Service';
    final category = booking['category']?.toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.build_rounded,
                  color: AppTheme.primaryDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Requested',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
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
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Confirmed',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          if (category != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.outlineLight),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.category_rounded,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  'Category: ',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  category,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Technician Card ──────────────────────────────────────────────────────────

class _TechnicianCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _TechnicianCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final techName = booking['technician']?.toString() ?? 'Assigned Technician';
    final rating = (booking['technicianRating'] as num?)?.toDouble() ?? 4.8;
    final jobs = (booking['technicianJobs'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C896), Color(0xFF009B74)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                techName.isNotEmpty ? techName[0].toUpperCase() : 'T',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned Technician',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  techName,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                    if (jobs > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$jobs jobs',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 13,
                  color: Color(0xFF3B82F6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Verified',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B82F6),
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

// ─── Info Tile (Date/Time & Location) ─────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ─── Issue Description Card ───────────────────────────────────────────────────

class _IssueCard extends StatelessWidget {
  final String description;

  const _IssueCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_rounded,
              size: 18,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Issue Description',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondary,
                    height: 1.5,
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

// ─── Price Breakdown Card ─────────────────────────────────────────────────────

class _PriceBreakdownCard extends StatelessWidget {
  final int basePrice;
  final int convenienceFee;
  final int gst;
  final int total;

  const _PriceBreakdownCard({
    required this.basePrice,
    required this.convenienceFee,
    required this.gst,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 18,
                color: AppTheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Price Breakdown',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PriceRow(label: 'Service Charge', amount: basePrice),
          const SizedBox(height: 10),
          _PriceRow(label: 'Platform Fee', amount: convenienceFee),
          const SizedBox(height: 10),
          _PriceRow(label: 'GST (18%)', amount: gst),
          const SizedBox(height: 14),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.outlineLight,
                  AppTheme.primary.withAlpha(80),
                  AppTheme.outlineLight,
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹$total',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final int amount;

  const _PriceRow({required this.label, required this.amount});

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

// ─── Cancellation Policy Note ─────────────────────────────────────────────────

class _CancellationPolicyNote extends StatelessWidget {
  const _CancellationPolicyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppTheme.primaryDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Free cancellation up to 2 hours before the scheduled time. A ₹49 fee applies for late cancellations.',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppTheme.primaryDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom CTA ───────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  final int total;
  final VoidCallback onTap;

  const _BottomCta({required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        border: const Border(top: BorderSide(color: AppTheme.outlineLight)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Payable',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                '₹$total',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed to Payment',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
