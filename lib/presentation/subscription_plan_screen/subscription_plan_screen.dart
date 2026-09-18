import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen>
    with TickerProviderStateMixin {
  int _selectedPlan = 1; // default to Pro
  bool _isAnnual = true;
  bool _isPurchasing = false;

  late final AnimationController _headerController;
  late final Animation<double> _headerFade;

  final List<_PlanData> _plans = const [
    _PlanData(
      id: 0,
      name: 'Basic',
      tagline: 'Get started with essentials',
      monthlyPrice: 299,
      annualPrice: 199,
      color: Color(0xFF64748B),
      gradientColors: [Color(0xFF64748B), Color(0xFF475569)],
      icon: Icons.shield_outlined,
      badge: null,
      benefits: [
        _Benefit('Priority booking', true),
        _Benefit('10% off all services', true),
        _Benefit('Email support', true),
        _Benefit('1 free inspection/year', true),
        _Benefit('30-min response time', false),
        _Benefit('Dedicated account manager', false),
        _Benefit('Unlimited free re-visits', false),
        _Benefit('24/7 emergency support', false),
      ],
    ),
    _PlanData(
      id: 1,
      name: 'Pro',
      tagline: 'Most popular for homeowners',
      monthlyPrice: 699,
      annualPrice: 499,
      color: Color(0xFF00C896),
      gradientColors: [Color(0xFF00C896), Color(0xFF009B74)],
      icon: Icons.verified_rounded,
      badge: 'MOST POPULAR',
      benefits: [
        _Benefit('Priority booking', true),
        _Benefit('20% off all services', true),
        _Benefit('24/7 chat support', true),
        _Benefit('3 free inspections/year', true),
        _Benefit('30-min response time', true),
        _Benefit('Dedicated account manager', false),
        _Benefit('Unlimited free re-visits', false),
        _Benefit('24/7 emergency support', false),
      ],
    ),
    _PlanData(
      id: 2,
      name: 'Elite',
      tagline: 'Complete home care coverage',
      monthlyPrice: 1299,
      annualPrice: 999,
      color: Color(0xFFF59E0B),
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      icon: Icons.workspace_premium_rounded,
      badge: 'BEST VALUE',
      benefits: [
        _Benefit('Priority booking', true),
        _Benefit('30% off all services', true),
        _Benefit('24/7 phone + chat support', true),
        _Benefit('Unlimited free inspections', true),
        _Benefit('15-min response time', true),
        _Benefit('Dedicated account manager', true),
        _Benefit('Unlimited free re-visits', true),
        _Benefit('24/7 emergency support', true),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  int _getPrice(_PlanData plan) =>
      _isAnnual ? plan.annualPrice : plan.monthlyPrice;

  int _getSavings(_PlanData plan) =>
      (plan.monthlyPrice - plan.annualPrice) * 12;

  void _onPurchase() async {
    final plan = _plans[_selectedPlan];
    setState(() => _isPurchasing = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PurchaseConfirmSheet(
        plan: plan,
        isAnnual: _isAnnual,
        price: _getPrice(plan),
        onConfirm: () {
          Navigator.pop(context);
          _processPayment(plan);
        },
        onCancel: () {
          Navigator.pop(context);
          setState(() => _isPurchasing = false);
        },
      ),
    );

    setState(() => _isPurchasing = false);
  }

  void _processPayment(_PlanData plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentProcessingDialog(
        plan: plan,
        isAnnual: _isAnnual,
        price: _getPrice(plan),
        onSuccess: () {
          Navigator.pop(context);
          _showSuccessSheet(plan);
        },
      ),
    );
  }

  void _showSuccessSheet(_PlanData plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _SuccessSheet(
        plan: plan,
        onDone: () {
          Navigator.pop(context);
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _headerFade,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildBillingToggle(),
                  const SizedBox(height: 8),
                  _buildPlanCards(),
                  _buildBenefitsComparison(),
                  _buildFAQ(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomCTA(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.backgroundLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.outlineLight),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: Color(0xFF1A1A2E),
          ),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Choose Your Plan',
        style: GoogleFonts.manrope(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppTheme.primary.withAlpha(60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'FIXIQO CARE PLANS',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Unlock Premium\nHome Care',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Priority service, exclusive discounts, and\ndedicated support — all in one plan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppTheme.outlineLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isAnnual = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !_isAnnual ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Monthly',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: !_isAnnual
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isAnnual = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _isAnnual ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Annual',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isAnnual
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _isAnnual
                              ? Colors.white.withAlpha(40)
                              : const Color(0xFFF59E0B).withAlpha(30),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Save 30%',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _isAnnual
                                ? Colors.white
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCards() {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        itemCount: _plans.length,
        itemBuilder: (context, i) {
          final plan = _plans[i];
          final isSelected = _selectedPlan == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedPlan = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 200,
              margin: EdgeInsets.only(right: i < _plans.length - 1 ? 14 : 0),
              decoration: BoxDecoration(
                color: isSelected ? plan.color : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? plan.color : AppTheme.outlineLight,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? plan.color.withAlpha(60)
                        : Colors.black.withAlpha(12),
                    blurRadius: isSelected ? 20 : 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (isSelected)
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(15),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (plan.badge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withAlpha(40)
                                  : plan.color.withAlpha(20),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              plan.badge!,
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : plan.color,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ] else
                          const SizedBox(height: 20),
                        Icon(
                          plan.icon,
                          color: isSelected ? Colors.white : plan.color,
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          plan.name,
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.tagline,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white.withAlpha(200)
                                : const Color(0xFF64748B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${_getPrice(plan)}',
                              style: GoogleFonts.manrope(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '/mo',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white.withAlpha(180)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_isAnnual)
                          Text(
                            'Save ₹${_getSavings(plan)}/yr',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white.withAlpha(200)
                                  : const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: plan.color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefitsComparison() {
    final plan = _plans[_selectedPlan];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: plan.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${plan.name} Plan Includes',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.outlineLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: List.generate(plan.benefits.length, (i) {
                final benefit = plan.benefits[i];
                final isLast = i == plan.benefits.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: benefit.included
                                  ? plan.color.withAlpha(20)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              benefit.included
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              size: 16,
                              color: benefit.included
                                  ? plan.color
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              benefit.label,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: benefit.included
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                color: benefit.included
                                    ? const Color(0xFF1A1A2E)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: AppTheme.outlineVariantLight,
                        indent: 18,
                        endIndent: 18,
                      ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          // Compare all plans hint
          _buildPlanComparisonRow(),
        ],
      ),
    );
  }

  Widget _buildPlanComparisonRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Not sure which plan?',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap a plan card above to compare benefits',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: _plans.map((p) {
              final isSelected = _selectedPlan == p.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedPlan = p.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? p.color : p.color.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? p.color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    p.icon,
                    size: 14,
                    color: isSelected ? Colors.white : p.color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    final faqs = [
      _FAQ(
        'Can I cancel anytime?',
        'Yes, you can cancel your subscription at any time. Your plan remains active until the end of the billing period.',
      ),
      _FAQ(
        'What happens after my plan expires?',
        'You\'ll revert to standard pricing and lose access to priority booking and discounts. You can renew anytime.',
      ),
      _FAQ(
        'Are there any hidden charges?',
        'No hidden charges. The price you see is what you pay. Service charges are separate and shown before booking.',
      ),
      _FAQ(
        'Can I upgrade or downgrade my plan?',
        'Yes, you can switch plans at any time. Upgrades take effect immediately; downgrades apply at the next billing cycle.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Frequently Asked',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...faqs.map((faq) => _FAQItem(faq: faq)),
        ],
      ),
    );
  }

  Widget _buildBottomCTA() {
    final plan = _plans[_selectedPlan];
    final price = _getPrice(plan);
    final total = _isAnnual ? price * 12 : price;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.outlineLight)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.name} Plan · ${_isAnnual ? 'Annual' : 'Monthly'}',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹$total',
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1A2E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            _isAnnual ? '/year' : '/month',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _isPurchasing ? null : _onPurchase,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: plan.gradientColors),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: plan.color.withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _isPurchasing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Get ${plan.name}',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '7-day free trial · No commitment · Cancel anytime',
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

// ─── Data Models ─────────────────────────────────────────────────────────────

class _PlanData {
  final int id;
  final String name;
  final String tagline;
  final int monthlyPrice;
  final int annualPrice;
  final Color color;
  final List<Color> gradientColors;
  final IconData icon;
  final String? badge;
  final List<_Benefit> benefits;

  const _PlanData({
    required this.id,
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.color,
    required this.gradientColors,
    required this.icon,
    required this.badge,
    required this.benefits,
  });
}

class _Benefit {
  final String label;
  final bool included;
  const _Benefit(this.label, this.included);
}

class _FAQ {
  final String question;
  final String answer;
  const _FAQ(this.question, this.answer);
}

// ─── FAQ Item ─────────────────────────────────────────────────────────────────

class _FAQItem extends StatefulWidget {
  final _FAQ faq;
  const _FAQItem({required this.faq});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _expanded
              ? AppTheme.primary.withAlpha(80)
              : AppTheme.outlineLight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.faq.question,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _expanded
                              ? AppTheme.primary
                              : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        widget.faq.answer,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Purchase Confirm Sheet ───────────────────────────────────────────────────

class _PurchaseConfirmSheet extends StatelessWidget {
  final _PlanData plan;
  final bool isAnnual;
  final int price;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _PurchaseConfirmSheet({
    required this.plan,
    required this.isAnnual,
    required this.price,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final total = isAnnual ? price * 12 : price;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: plan.color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(plan.icon, color: plan.color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm Purchase',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${plan.name} Plan · ${isAnnual ? 'Annual' : 'Monthly'} Billing',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.outlineLight),
              ),
              child: Column(
                children: [
                  _SummaryRow('Plan', plan.name),
                  const SizedBox(height: 8),
                  _SummaryRow('Billing', isAnnual ? 'Annual' : 'Monthly'),
                  const SizedBox(height: 8),
                  _SummaryRow('Free Trial', '7 days'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        '₹$total${isAnnual ? '/year' : '/month'}',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: plan.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Proceed to Payment',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onCancel,
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

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
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

// ─── Payment Processing Dialog ────────────────────────────────────────────────

class _PaymentProcessingDialog extends StatefulWidget {
  final _PlanData plan;
  final bool isAnnual;
  final int price;
  final VoidCallback onSuccess;

  const _PaymentProcessingDialog({
    required this.plan,
    required this.isAnnual,
    required this.price,
    required this.onSuccess,
  });

  @override
  State<_PaymentProcessingDialog> createState() =>
      _PaymentProcessingDialogState();
}

class _PaymentProcessingDialogState extends State<_PaymentProcessingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onSuccess();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.plan.color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sync_rounded,
                  color: widget.plan.color,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Processing Payment',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we activate\nyour ${widget.plan.name} plan...',
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

// ─── Success Sheet ────────────────────────────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  final _PlanData plan;
  final VoidCallback onDone;

  const _SuccessSheet({required this.plan, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: plan.color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: plan.color,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to ${plan.name}! 🎉',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your ${plan.name} plan is now active. Enjoy priority service, exclusive discounts, and premium support.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: plan.color.withAlpha(12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: plan.color.withAlpha(40)),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded, color: plan.color, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your 7-day free trial starts today. You won\'t be charged until it ends.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF1A1A2E),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Exploring',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
