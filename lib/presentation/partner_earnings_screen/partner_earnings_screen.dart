import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../services/partner_earnings_service.dart';

// ── Fixiqo Earnings Palette ───────────────────────────────────────
const _bg = Color(0xFFF8FAFC);
const _surface = Color(0xFFFFFFFF);
const _textMain = Color(0xFF0F172A);
const _textSub = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _accent = Color(0xFF6366F1);
const _accentLight = Color(0xFFEEF2FF);
const _green = Color(0xFF10B981);
const _greenLight = Color(0xFFD1FAE5);
const _amber = Color(0xFFF59E0B);
const _amberLight = Color(0xFFFEF3C7);
const _blue = Color(0xFF3B82F6);
const _blueLight = Color(0xFFDBEAFE);
// ─────────────────────────────────────────────────────────────────

class PartnerEarningsScreen extends StatefulWidget {
  const PartnerEarningsScreen({super.key});

  @override
  State<PartnerEarningsScreen> createState() => _PartnerEarningsScreenState();
}

class _PartnerEarningsScreenState extends State<PartnerEarningsScreen>
    with SingleTickerProviderStateMixin {
  PartnerEarningsSummary? _summary;
  bool _isLoading = true;
  String? _error;
  int _touchedBarIndex = -1;
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
    _loadEarnings();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadEarnings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final summary = await PartnerEarningsService.instance
          .fetchEarningsSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
        _fadeController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load earnings. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(int amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹$amount';
  }

  String _formatFullCurrency(int amount) {
    final str = amount.toString();
    if (str.length > 3) {
      final parts = <String>[];
      var remaining = str;
      while (remaining.length > 3) {
        parts.insert(0, remaining.substring(remaining.length - 3));
        remaining = remaining.substring(0, remaining.length - 3);
      }
      parts.insert(0, remaining);
      return '₹${parts.join(',')}';
    }
    return '₹$str';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _isLoading
            ? _buildSkeleton()
            : _error != null
            ? _buildError()
            : FadeTransition(
                opacity: _fadeAnim,
                child: RefreshIndicator(
                  onRefresh: _loadEarnings,
                  color: AppTheme.primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      SliverToBoxAdapter(child: _buildStatsGrid()),
                      SliverToBoxAdapter(child: _buildChartSection()),
                      SliverToBoxAdapter(child: _buildTransactionHeader()),
                      _buildTransactionList(),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Earnings',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track your income and performance',
                  style: GoogleFonts.dmSans(fontSize: 13, color: _textSub),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadEarnings,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: _textSub,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final s = _summary!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Total earnings hero card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withAlpha(60),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Total Earnings',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _formatFullCurrency(s.totalEarnings),
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        'This month: ${_formatCurrency(s.thisMonthEarnings)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.white.withAlpha(220),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_rounded,
                  iconColor: _green,
                  iconBg: _greenLight,
                  label: 'Completed Jobs',
                  value: '${s.completedJobs}',
                  sub: 'All time',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.star_rounded,
                  iconColor: _amber,
                  iconBg: _amberLight,
                  label: 'Avg Rating',
                  value: s.averageRating > 0
                      ? s.averageRating.toStringAsFixed(1)
                      : '—',
                  sub: s.averageRating > 0 ? '★ out of 5' : 'No ratings yet',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final s = _summary!;
    if (s.monthlyData.isEmpty) return const SizedBox.shrink();

    final maxAmount = s.monthlyData
        .map((m) => m.amount)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final chartMax = maxAmount == 0 ? 1000.0 : (maxAmount * 1.25).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Monthly Income',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accentLight,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    'Last 6 months',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: chartMax,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      setState(() {
                        _touchedBarIndex =
                            response?.spot?.touchedBarGroupIndex ?? -1;
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: _textMain,
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final m = s.monthlyData[groupIndex];
                        return BarTooltipItem(
                          '${m.month}\n${_formatCurrency(m.amount)}',
                          GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= s.monthlyData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              s.monthlyData[idx].month,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: _textSub,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return Text(
                              '₹0',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: _textSub,
                              ),
                            );
                          }
                          if (value == chartMax) {
                            return Text(
                              _formatCurrency(value.toInt()),
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: _textSub,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: chartMax / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: _border,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(s.monthlyData.length, (i) {
                    final m = s.monthlyData[i];
                    final isTouched = i == _touchedBarIndex;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: m.amount.toDouble(),
                          width: 22,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isTouched
                                ? [
                                    const Color(0xFF7C3AED),
                                    const Color(0xFF4F46E5),
                                  ]
                                : [_accent.withAlpha(120), _accent],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    final count = _summary?.transactions.length ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text(
            'Transaction History',
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _textMain,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _blueLight,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              '$count jobs',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: _blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactions = _summary?.transactions ?? [];
    if (transactions.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _accentLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: _accent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete jobs to see your earnings here',
                  style: GoogleFonts.dmSans(fontSize: 13, color: _textSub),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final t = transactions[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            index == transactions.length - 1 ? 0 : 10,
          ),
          child: _TransactionCard(
            transaction: t,
            formatCurrency: _formatFullCurrency,
          ),
        );
      }, childCount: transactions.length),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _SkeletonBox(height: 28, width: 160),
          const SizedBox(height: 8),
          _SkeletonBox(height: 14, width: 220),
          const SizedBox(height: 24),
          _SkeletonBox(height: 120, width: double.infinity),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SkeletonBox(height: 90, width: double.infinity)),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonBox(height: 90, width: double.infinity)),
            ],
          ),
          const SizedBox(height: 20),
          _SkeletonBox(height: 220, width: double.infinity),
          const SizedBox(height: 20),
          ...List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SkeletonBox(height: 80, width: double.infinity),
            ),
          ),
        ],
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: _textSub),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadEarnings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String sub;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
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
              color: iconBg,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textMain,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            sub,
            style: GoogleFonts.dmSans(fontSize: 11, color: _textSub),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Transaction Card ──────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final EarningsTransaction transaction;
  final String Function(int) formatCurrency;

  const _TransactionCard({
    required this.transaction,
    required this.formatCurrency,
  });

  IconData _serviceIcon(String service) {
    final s = service.toLowerCase();
    if (s.contains('ac') || s.contains('air')) return Icons.ac_unit_rounded;
    if (s.contains('plumb')) return Icons.plumbing_rounded;
    if (s.contains('electr')) return Icons.electrical_services_rounded;
    if (s.contains('carp')) return Icons.handyman_rounded;
    if (s.contains('clean')) return Icons.cleaning_services_rounded;
    if (s.contains('paint')) return Icons.format_paint_rounded;
    return Icons.build_rounded;
  }

  String _formatDate(DateTime dt) {
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final rating = transaction.customerRating;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              _serviceIcon(transaction.service),
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.service,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.customerName,
                  style: GoogleFonts.dmSans(fontSize: 12, color: _textSub),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: _textSub,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatDate(transaction.completedAt),
                      style: GoogleFonts.dmSans(fontSize: 11, color: _textSub),
                    ),
                    if (rating != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded, size: 12, color: _amber),
                      const SizedBox(width: 2),
                      Text(
                        '$rating',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: _textSub,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(transaction.amount),
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _green,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _greenLight,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  'Paid',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: _green,
                    fontWeight: FontWeight.w700,
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

// ── Skeleton Box ──────────────────────────────────────────────────

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double width;

  const _SkeletonBox({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}