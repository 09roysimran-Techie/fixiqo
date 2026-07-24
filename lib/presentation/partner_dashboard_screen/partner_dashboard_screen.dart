import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  int _selectedIndex = 0;
  bool _isOnline = false;

  final List<_PartnerTab> _tabs = const [
    _PartnerTab(
      icon: Icons.wifi_tethering_rounded,
      activeIcon: Icons.wifi_tethering_rounded,
      label: 'Go Online',
    ),
    _PartnerTab(
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      label: 'Job Queue',
    ),
    _PartnerTab(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Earnings',
    ),
    _PartnerTab(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      label: 'Documents',
    ),
    _PartnerTab(
      icon: Icons.star_outline_rounded,
      activeIcon: Icons.star_rounded,
      label: 'Ratings',
    ),
    _PartnerTab(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return _GoOnlineTab(
          isOnline: _isOnline,
          onToggle: (v) => setState(() => _isOnline = v),
        );
      case 1:
        return const _JobQueueTab();
      case 2:
        return const _EarningsTab();
      case 3:
        return const _DocumentsTab();
      case 4:
        return const _RatingsTab();
      case 5:
        return _PartnerProfileTab(
          onSwitchRole: () => context.go(AppRoutes.roleSelectionScreen),
        );
      default:
        return _GoOnlineTab(
          isOnline: _isOnline,
          onToggle: (v) => setState(() => _isOnline = v),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: _buildCurrentTab(),
      bottomNavigationBar: _PartnerBottomNav(
        selectedIndex: _selectedIndex,
        tabs: _tabs,
        onTap: (i) => setState(() => _selectedIndex = i),
        isOnline: _isOnline,
      ),
    );
  }
}

class _PartnerTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _PartnerTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _PartnerBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<_PartnerTab> tabs;
  final ValueChanged<int> onTap;
  final bool isOnline;

  const _PartnerBottomNav({
    required this.selectedIndex,
    required this.tabs,
    required this.onTap,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(46),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (i) {
            final tab = tabs[i];
            final isActive = i == selectedIndex;
            final isGoOnline = i == 0;
            final activeColor = isGoOnline
                ? (isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                : AppTheme.primary;

            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 48,
                height: 68,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      width: isActive ? 40 : 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isActive
                            ? activeColor.withAlpha(51)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        isActive ? tab.activeIcon : tab.icon,
                        color: isActive
                            ? activeColor
                            : Colors.white.withAlpha(153),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isActive
                            ? activeColor
                            : Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Go Online Tab ───────────────────────────────────────────────────────────

class _GoOnlineTab extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const _GoOnlineTab({required this.isOnline, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PartnerAppBar(title: 'Go Online'),
            const SizedBox(height: 24),
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isOnline
                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                      : [const Color(0xFF374151), const Color(0xFF1F2937)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isOnline ? const Color(0xFF10B981) : Colors.black)
                        .withAlpha(50),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isOnline
                        ? Icons.wifi_tethering_rounded
                        : Icons.wifi_tethering_off_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isOnline ? 'You\'re Online' : 'You\'re Offline',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isOnline
                        ? 'Accepting new job requests in your area'
                        : 'Go online to start receiving job requests',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => onToggle(!isOnline),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        isOnline ? 'Go Offline' : 'Go Online',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isOnline
                              ? const Color(0xFF10B981)
                              : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Today\'s Jobs',
                    value: '3',
                    icon: Icons.work_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Today\'s Earnings',
                    value: '₹1,240',
                    icon: Icons.currency_rupee_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Rating',
                    value: '4.8 ★',
                    icon: Icons.star_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Completion',
                    value: '96%',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Service Area',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
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
                          'Koramangala, Bangalore',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          '5 km radius',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Change',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
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
}

// ─── Job Queue Tab ────────────────────────────────────────────────────────────

class _JobQueueTab extends StatelessWidget {
  const _JobQueueTab();

  @override
  Widget build(BuildContext context) {
    final jobs = [
      {
        'title': 'AC Repair',
        'customer': 'Rahul Sharma',
        'address': 'Indiranagar, Bangalore',
        'price': '₹850',
        'time': '2:30 PM',
        'status': 'New',
        'icon': Icons.ac_unit_rounded,
      },
      {
        'title': 'Plumbing Fix',
        'customer': 'Priya Nair',
        'address': 'HSR Layout, Bangalore',
        'price': '₹600',
        'time': '4:00 PM',
        'status': 'Accepted',
        'icon': Icons.plumbing_rounded,
      },
      {
        'title': 'Electrical Work',
        'customer': 'Amit Patel',
        'address': 'Whitefield, Bangalore',
        'price': '₹1,200',
        'time': '5:30 PM',
        'status': 'New',
        'icon': Icons.electrical_services_rounded,
      },
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _PartnerAppBar(title: 'Job Queue'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final job = jobs[i];
                final isNew = job['status'] == 'New';
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isNew
                          ? AppTheme.primary.withAlpha(80)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 8,
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
                              color: AppTheme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              job['icon'] as IconData,
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
                                  job['title'] as String,
                                  style: GoogleFonts.manrope(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                Text(
                                  job['customer'] as String,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isNew
                                  ? AppTheme.primary.withAlpha(25)
                                  : const Color(0xFF3B82F6).withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              job['status'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isNew
                                    ? AppTheme.primary
                                    : const Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job['address'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job['time'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            job['price'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          const Spacer(),
                          if (isNew) ...[
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFEF4444),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Decline',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: const Color(0xFFEF4444),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Accept',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ] else
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'View Details',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Earnings Tab ─────────────────────────────────────────────────────────────

class _EarningsTab extends StatelessWidget {
  const _EarningsTab();

  @override
  Widget build(BuildContext context) {
    final history = [
      {
        'title': 'AC Repair',
        'date': 'Today, 2:30 PM',
        'amount': '+₹850',
        'status': 'Paid',
      },
      {
        'title': 'Plumbing Fix',
        'date': 'Yesterday, 11:00 AM',
        'amount': '+₹600',
        'status': 'Paid',
      },
      {
        'title': 'Electrical Work',
        'date': 'Jul 22, 5:30 PM',
        'amount': '+₹1,200',
        'status': 'Paid',
      },
      {
        'title': 'Carpentry',
        'date': 'Jul 21, 3:00 PM',
        'amount': '+₹950',
        'status': 'Paid',
      },
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PartnerAppBar(title: 'Earnings'),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF0A2540)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Earnings',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹24,850',
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This month',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _EarningsStat(label: 'This Week', value: '₹6,200'),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withAlpha(30),
                      ),
                      _EarningsStat(label: 'Today', value: '₹850'),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withAlpha(30),
                      ),
                      _EarningsStat(label: 'Jobs Done', value: '28'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Transaction History',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            ...history.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.currency_rupee_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            item['date']!,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['amount']!,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          item['status']!,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsStat extends StatelessWidget {
  final String label;
  final String value;
  const _EarningsStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            color: Colors.white.withAlpha(160),
          ),
        ),
      ],
    );
  }
}

// ─── Documents Tab ────────────────────────────────────────────────────────────

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab();

  @override
  Widget build(BuildContext context) {
    final docs = [
      {
        'title': 'Aadhaar Card',
        'status': 'Verified',
        'icon': Icons.badge_rounded,
        'verified': true,
      },
      {
        'title': 'PAN Card',
        'status': 'Verified',
        'icon': Icons.credit_card_rounded,
        'verified': true,
      },
      {
        'title': 'Skill Certificate',
        'status': 'Pending Review',
        'icon': Icons.workspace_premium_rounded,
        'verified': false,
      },
      {
        'title': 'Bank Account',
        'status': 'Verified',
        'icon': Icons.account_balance_rounded,
        'verified': true,
      },
      {
        'title': 'Profile Photo',
        'status': 'Upload Required',
        'icon': Icons.photo_camera_rounded,
        'verified': false,
      },
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PartnerAppBar(title: 'Documents'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withAlpha(60),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Keep your documents up to date to avoid service interruptions.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...docs.map((doc) {
              final verified = doc['verified'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (verified
                                    ? AppTheme.primary
                                    : const Color(0xFFF59E0B))
                                .withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        doc['icon'] as IconData,
                        color: verified
                            ? AppTheme.primary
                            : const Color(0xFFF59E0B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['title'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            doc['status'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: verified
                                  ? AppTheme.primary
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (verified)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      )
                    else
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: Text(
                          'Upload',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Ratings Tab ──────────────────────────────────────────────────────────────

class _RatingsTab extends StatelessWidget {
  const _RatingsTab();

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        'name': 'Rahul Sharma',
        'rating': 5,
        'comment': 'Excellent work! Very professional and on time.',
        'date': 'Jul 23',
        'service': 'AC Repair',
      },
      {
        'name': 'Priya Nair',
        'rating': 5,
        'comment': 'Fixed the issue quickly. Highly recommended!',
        'date': 'Jul 22',
        'service': 'Plumbing',
      },
      {
        'name': 'Amit Patel',
        'rating': 4,
        'comment': 'Good work, explained everything clearly.',
        'date': 'Jul 21',
        'service': 'Electrical',
      },
      {
        'name': 'Sneha Reddy',
        'rating': 5,
        'comment': 'Very neat and clean work. Will book again.',
        'date': 'Jul 20',
        'service': 'Carpentry',
      },
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PartnerAppBar(title: 'Ratings'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF0A2540)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '4.8',
                        style: GoogleFonts.manrope(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < 4
                                ? Icons.star_rounded
                                : Icons.star_half_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on 28 reviews',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.white.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [5, 4, 3, 2, 1].map((star) {
                        final pct = star == 5
                            ? 0.75
                            : star == 4
                            ? 0.18
                            : star == 3
                            ? 0.05
                            : 0.02;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '$star',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: Colors.white.withAlpha(180),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: Colors.white.withAlpha(30),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFF59E0B),
                                        ),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Reviews',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            ...reviews.map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primary.withAlpha(30),
                          child: Text(
                            (r['name'] as String)[0],
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['name'] as String,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              Text(
                                '${r['service']} • ${r['date']}',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            r['rating'] as int,
                            (_) => const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      r['comment'] as String,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Partner Profile Tab ──────────────────────────────────────────────────────

class _PartnerProfileTab extends StatelessWidget {
  final VoidCallback onSwitchRole;
  const _PartnerProfileTab({required this.onSwitchRole});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PartnerAppBar(title: 'Profile'),
            const SizedBox(height: 20),
            // Profile header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF0A2540)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primary.withAlpha(40),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ravi Kumar',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'AC & Electrical Specialist',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: Colors.white.withAlpha(180),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.8 • 28 jobs',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ProfileMenuItem(
              icon: Icons.edit_rounded,
              label: 'Edit Profile',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            // Switch role button
            GestureDetector(
              onTap: onSwitchRole,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
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
                            'Switch to Customer',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            'Browse and book services',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppTheme.primary.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.primary,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ProfileMenuItem(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              onTap: () => context.go(AppRoutes.signUpLoginScreen),
              color: const Color(0xFFEF4444),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF1A1A2E);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: c,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: c.withAlpha(100),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _PartnerAppBar extends StatelessWidget {
  final String title;
  const _PartnerAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF3B82F6).withAlpha(60)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.engineering_rounded,
                color: Color(0xFF3B82F6),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Partner',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
