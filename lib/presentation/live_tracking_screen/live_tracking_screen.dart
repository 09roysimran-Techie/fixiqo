import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './widgets/booking_summary_widget.dart';
import './widgets/job_status_timeline_widget.dart';
import './widgets/technician_info_card_widget.dart';
import './widgets/tracking_action_buttons_widget.dart';
import './widgets/tracking_map_widget.dart';

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

  final Map<String, dynamic> _booking = {
    'id': 'FXQ-20240723-4892',
    'service': 'Electrical Repair',
    'issue': 'Circuit breaker tripping repeatedly',
    'address': '142 Maple Grove Drive, Unit 3B',
    'price': 499,
    'eta': 14,
    'distance': '1.8 km',
    'currentStatus': 2,
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
      duration: const Duration(milliseconds: 600),
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
      backgroundColor: const Color(0xFF080E1A),
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
        // Dark gradient background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF080E1A),
                  Color(0xFF0D1B2A),
                  Color(0xFF0A1628),
                ],
              ),
            ),
          ),
        ),

        // Ambient teal glow top-left
        Positioned(
          top: -60,
          left: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00C896).withAlpha(46),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Ambient orange glow top-right
        Positioned(
          top: 40,
          right: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF6B35).withAlpha(31),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

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

        // Scrollable dark bottom panel
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
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2A),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFF00C896).withAlpha(64),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C896).withAlpha(20),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
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
                              color: const Color(0xFF00C896).withAlpha(89),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        // Live tracking label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00C896),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'LIVE TRACKING',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00C896),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TechnicianInfoCardWidget(
                          technician:
                              _booking['technician'] as Map<String, dynamic>,
                          eta: _booking['eta'] as int,
                          distance: _booking['distance'] as String,
                        ),
                        const SizedBox(height: 16),
                        TrackingActionButtonsWidget(
                          technicianPhone:
                              (_booking['technician']
                                      as Map<String, dynamic>)['phone']
                                  as String,
                          onCall: () {},
                          onChat: () {},
                        ),
                        const SizedBox(height: 16),
                        JobStatusTimelineWidget(
                          currentStatusIndex: _booking['currentStatus'] as int,
                        ),
                        const SizedBox(height: 16),
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D1B2A), Color(0xFF080E1A)],
              ),
              border: Border(
                left: BorderSide(color: Color(0xFF1A2E40), width: 1),
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPadding + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C896),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'LIVE TRACKING',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00C896),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TechnicianInfoCardWidget(
                      technician:
                          _booking['technician'] as Map<String, dynamic>,
                      eta: _booking['eta'] as int,
                      distance: _booking['distance'] as String,
                    ),
                    const SizedBox(height: 16),
                    TrackingActionButtonsWidget(
                      technicianPhone:
                          (_booking['technician']
                                  as Map<String, dynamic>)['phone']
                              as String,
                      onCall: () {},
                      onChat: () {},
                    ),
                    const SizedBox(height: 16),
                    JobStatusTimelineWidget(
                      currentStatusIndex: _booking['currentStatus'] as int,
                    ),
                    const SizedBox(height: 16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A).withAlpha(191),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00C896).withAlpha(77),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFFE2E8F0),
            ),
          ),
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
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C896), Color(0xFF009B74)],
              ),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C896).withAlpha(115),
                  blurRadius: 16,
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
        ),
      ),
    );
  }
}
