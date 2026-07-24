import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import './widgets/booking_summary_widget.dart';
import './widgets/job_status_timeline_widget.dart';
import './widgets/technician_info_card_widget.dart';
import './widgets/tracking_action_buttons_widget.dart';
import './widgets/tracking_map_widget.dart';

// TODO: Replace with Riverpod/Bloc for production state management
// TODO: Replace mock location data with real-time GPS stream

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<Offset> _panelSlide;
  late Animation<double> _panelOpacity;

  // Mock booking data
  final Map<String, dynamic> _booking = {
    'id': 'FXQ-20240723-4892',
    'service': 'Electrical Repair',
    'issue': 'Circuit breaker tripping repeatedly',
    'address': '142 Maple Grove Drive, Unit 3B',
    'price': 499,
    'eta': 14,
    'distance': '1.8 km',
    'currentStatus':
        2, // 0=searching,1=assigned,2=enRoute,3=arrived,4=inProgress,5=completed
    'technician': {
      'name': 'Rahim Uddin',
      'specialty': 'Master Electrician',
      'rating': 4.9,
      'reviews': 142,
      'phone': '+1 (555) 234-7891',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_193df7de3-1782816308433.png',
      'semanticLabel':
          'Male electrician in orange uniform with hard hat, arms crossed, professional headshot',
      'badge': 'Certified',
      'completedJobs': 847,
    },
  };

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _panelSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _panelOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7),
      ),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: isTablet
          ? _buildTabletLayout(context, bottomPadding)
          : _buildPhoneLayout(context, size, bottomPadding),
    );
  }

  Widget _buildPhoneLayout(
    BuildContext context,
    Size size,
    double bottomPadding,
  ) {
    return Stack(
      children: [
        // Map takes top 45%
        TrackingMapWidget(
          height: size.height * 0.45,
          technicianEta: _booking['eta'] as int,
        ),

        // Back button overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          child: _BackButton(onTap: () => context.pop()),
        ),

        // Status badge overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 16,
          child: _EtaBadge(eta: _booking['eta'] as int),
        ),

        // Scrollable bottom panel
        Positioned(
          top: size.height * 0.42,
          left: 0,
          right: 0,
          bottom: 0,
          child: FadeTransition(
            opacity: _panelOpacity,
            child: SlideTransition(
              position: _panelSlide,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPadding + 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        TechnicianInfoCardWidget(
                          technician:
                              _booking['technician'] as Map<String, dynamic>,
                          eta: _booking['eta'] as int,
                          distance: _booking['distance'] as String,
                        ),
                        const SizedBox(height: 20),
                        TrackingActionButtonsWidget(
                          technicianPhone:
                              (_booking['technician']
                                      as Map<String, dynamic>)['phone']
                                  as String,
                          onCall: () {},
                          onChat: () {},
                        ),
                        const SizedBox(height: 20),
                        JobStatusTimelineWidget(
                          currentStatusIndex: _booking['currentStatus'] as int,
                        ),
                        const SizedBox(height: 20),
                        BookingSummaryWidget(booking: _booking),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, double bottomPadding) {
    return Row(
      children: [
        // Map left 55%
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              TrackingMapWidget(
                height: double.infinity,
                technicianEta: _booking['eta'] as int,
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                child: _BackButton(onTap: () => context.pop()),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 16,
                child: _EtaBadge(eta: _booking['eta'] as int),
              ),
            ],
          ),
        ),
        // Info panel right 45%
        Expanded(
          flex: 45,
          child: Container(
            color: AppTheme.backgroundLight,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPadding + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TechnicianInfoCardWidget(
                      technician:
                          _booking['technician'] as Map<String, dynamic>,
                      eta: _booking['eta'] as int,
                      distance: _booking['distance'] as String,
                    ),
                    const SizedBox(height: 20),
                    TrackingActionButtonsWidget(
                      technicianPhone:
                          (_booking['technician']
                                  as Map<String, dynamic>)['phone']
                              as String,
                      onCall: () {},
                      onChat: () {},
                    ),
                    const SizedBox(height: 20),
                    JobStatusTimelineWidget(
                      currentStatusIndex: _booking['currentStatus'] as int,
                    ),
                    const SizedBox(height: 20),
                    BookingSummaryWidget(booking: _booking),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(31),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppTheme.secondary,
        ),
      ),
    );
  }
}

class _EtaBadge extends StatefulWidget {
  final int eta;

  const _EtaBadge({required this.eta});

  @override
  State<_EtaBadge> createState() => _EtaBadgeState();
}

class _EtaBadgeState extends State<_EtaBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withAlpha(102),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              '${widget.eta} min',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
