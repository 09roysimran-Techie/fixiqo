import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

// V2 — Floating Pill BottomNav
// Core technique: detached pill container floating above content, extendBody: true
// LOCKED: pill shape, BoxShadow, AnimatedContainer active indicator

class _TabSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? branchIndex; // null = stub tab

  const _TabSpec({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final bool isPartner;

  const AppNavigation({
    required this.navigationShell,
    this.isPartner = false,
    super.key,
  });

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedVisualIndex = 0;

  // Customer tabs — Home repairs / services layout
  static const List<_TabSpec> _customerTabs = [
    _TabSpec(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      branchIndex: 0,
    ),
    _TabSpec(
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: 'Bookings',
      branchIndex: 1,
    ),
    _TabSpec(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Messages',
      branchIndex: null,
    ),
    _TabSpec(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Alerts',
      branchIndex: null,
    ),
    _TabSpec(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      branchIndex: 3,
    ),
  ];

  // Partner tabs — Technician Job Queue layout
  static const List<_TabSpec> _partnerTabs = [
    _TabSpec(
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      label: 'Job Queue',
      branchIndex: 0,
    ),
    _TabSpec(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      label: 'My Jobs',
      branchIndex: 1,
    ),
    _TabSpec(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Earnings',
      branchIndex: 2,
    ),
    _TabSpec(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Messages',
      branchIndex: null,
    ),
    _TabSpec(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      branchIndex: 3,
    ),
  ];

  List<_TabSpec> get _tabs => widget.isPartner ? _partnerTabs : _customerTabs;

  void _onTabTap(int visualIndex) {
    final tab = _tabs[visualIndex];
    if (tab.branchIndex == null) return; // stub tab — silent ignore

    setState(() => _selectedVisualIndex = visualIndex);
    widget.navigationShell.goBranch(
      tab.branchIndex!,
      initialLocation: tab.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final isActive = i == _selectedVisualIndex;
            final isStub = tab.branchIndex == null;

            return GestureDetector(
              onTap: () => _onTabTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isStub ? 0.4 : 1.0,
                child: SizedBox(
                  width: 56,
                  height: 68,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        width: isActive ? 44 : 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primary.withAlpha(51)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          color: isActive
                              ? AppTheme.primary
                              : Colors.white.withAlpha(153),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? AppTheme.primary
                              : Colors.white.withAlpha(128),
                        ),
                        child: Text(tab.label),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
