import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_image_widget.dart';
import '../../services/job_status_service.dart';

// ── Fixiqo Dark Premium Palette ──────────────────────────────────
const _bg = Color(0xFF060C16); // deepest background
const _surface = Color(0xFF0C1524); // panel / card base
const _surfaceElevated = Color(0xFF111D2E); // elevated card
const _border = Color(0xFF1A2B40); // subtle border
const _borderAccent = Color(0xFF1E3A52); // slightly brighter border
const _labelMuted = Color(0xFF4E6680); // muted label text
const _textSub = Color(0xFF7A9BB5); // secondary text
const _textMain = Color(0xFFE2EDF5); // primary text
const _mapOverlay = Color(0xCC060C16); // map gradient overlay
// ─────────────────────────────────────────────────────────────────

enum JobStatus { accepted, enRoute, arrived, inService }

class PartnerNavigationScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const PartnerNavigationScreen({super.key, required this.job});

  @override
  State<PartnerNavigationScreen> createState() =>
      _PartnerNavigationScreenState();
}

class _PartnerNavigationScreenState extends State<PartnerNavigationScreen>
    with TickerProviderStateMixin {
  // Status
  JobStatus _currentStatus = JobStatus.accepted;

  // ETA countdown
  late int _etaMinutes;
  late int _etaSeconds;
  Timer? _etaTimer;

  // Animations
  late AnimationController _markerBounce;
  late AnimationController _rippleController;
  late AnimationController _panelEntrance;
  late AnimationController _statusPulse;
  late Animation<double> _bounceAnim;
  late Animation<double> _rippleAnim;
  late Animation<Offset> _panelSlide;
  late Animation<double> _panelOpacity;
  late Animation<double> _pulseAnim;

  // Simulated partner position (moves toward destination)
  double _partnerX = 0.25;
  double _partnerY = 0.60;
  Timer? _moveTimer;

  // ── Real-time: derive a stable job ID from the job map ──────────
  String get _jobId =>
      widget.job['id'] as String? ??
      widget.job['bookingId'] as String? ??
      'job_${widget.job['service']?.toString().replaceAll(' ', '_') ?? 'unknown'}';

  @override
  void initState() {
    super.initState();

    final etaStr = widget.job['eta'] as String? ?? '15 min';
    final etaNum = int.tryParse(etaStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 15;
    _etaMinutes = etaNum;
    _etaSeconds = 0;

    // Marker bounce
    _markerBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Ripple
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    // Panel entrance
    _panelEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Status pulse
    _statusPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(
      begin: 0.0,
      end: -7.0,
    ).animate(CurvedAnimation(parent: _markerBounce, curve: Curves.easeInOut));
    _rippleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _panelSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _panelEntrance, curve: Curves.easeOutCubic),
        );
    _panelOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _panelEntrance, curve: const Interval(0.0, 0.7)),
    );
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _statusPulse, curve: Curves.easeInOut));

    _panelEntrance.forward();
    _startEtaCountdown();
    _startPartnerMovement();

    // Publish initial "accepted" status so customer screen can pick it up
    _publishCurrentStatus(JobStatus.accepted);

    // Auto-advance to en route after 2s
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _advanceStatus(JobStatus.enRoute);
    });
  }

  void _startEtaCountdown() {
    _etaTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_etaSeconds > 0) {
          _etaSeconds--;
        } else if (_etaMinutes > 0) {
          _etaMinutes--;
          _etaSeconds = 59;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _startPartnerMovement() {
    _moveTimer = Timer.periodic(const Duration(milliseconds: 1800), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _partnerX = (_partnerX + 0.04).clamp(0.0, 0.72);
        _partnerY = (_partnerY - 0.025).clamp(0.25, 0.75);
      });
    });
  }

  void _advanceStatus(JobStatus next) {
    if (!mounted) return;
    setState(() => _currentStatus = next);
    // Publish the new status to Supabase so the customer screen updates live
    _publishCurrentStatus(next);
  }

  /// Maps the local [JobStatus] enum to the DB string value and publishes it.
  void _publishCurrentStatus(JobStatus status) {
    final statusStr = _jobStatusToString(status);
    JobStatusService.instance.publishStatus(
      jobId: _jobId,
      status: statusStr,
      bookingId: widget.job['bookingId'] as String?,
      partnerId: widget.job['partnerId'] as String?,
      customerId: widget.job['customerId'] as String?,
    );
  }

  String _jobStatusToString(JobStatus s) {
    switch (s) {
      case JobStatus.accepted:
        return JobStatusValue.accepted;
      case JobStatus.enRoute:
        return JobStatusValue.enRoute;
      case JobStatus.arrived:
        return JobStatusValue.arrived;
      case JobStatus.inService:
        return JobStatusValue.inService;
    }
  }

  @override
  void dispose() {
    _markerBounce.dispose();
    _rippleController.dispose();
    _panelEntrance.dispose();
    _statusPulse.dispose();
    _etaTimer?.cancel();
    _moveTimer?.cancel();
    super.dispose();
  }

  String get _etaLabel {
    if (_etaMinutes == 0 && _etaSeconds == 0) return 'Arrived';
    if (_etaSeconds == 0) return '$_etaMinutes min';
    return '$_etaMinutes:${_etaSeconds.toString().padLeft(2, '0')}';
  }

  Color _statusColor(JobStatus s) {
    switch (s) {
      case JobStatus.accepted:
        return AppTheme.info;
      case JobStatus.enRoute:
        return AppTheme.warning;
      case JobStatus.arrived:
        return AppTheme.primary;
      case JobStatus.inService:
        return AppTheme.success;
    }
  }

  String _statusLabel(JobStatus s) {
    switch (s) {
      case JobStatus.accepted:
        return 'Accepted';
      case JobStatus.enRoute:
        return 'En Route';
      case JobStatus.arrived:
        return 'Arrived';
      case JobStatus.inService:
        return 'In Service';
    }
  }

  IconData _statusIcon(JobStatus s) {
    switch (s) {
      case JobStatus.accepted:
        return Icons.check_circle_rounded;
      case JobStatus.enRoute:
        return Icons.directions_car_rounded;
      case JobStatus.arrived:
        return Icons.location_on_rounded;
      case JobStatus.inService:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Map layer ──────────────────────────────────────────────
          _buildMap(size),

          // ── Top bar ────────────────────────────────────────────────
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: _buildTopBar(),
          ),

          // ── Bottom panel ───────────────────────────────────────────
          Positioned(
            top: size.height * 0.44,
            left: 0,
            right: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _panelOpacity,
              child: SlideTransition(
                position: _panelSlide,
                child: _buildBottomPanel(bottomPadding),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // MAP
  // ─────────────────────────────────────────────────────────────────
  Widget _buildMap(Size size) {
    return SizedBox(
      height: size.height * 0.50,
      child: Stack(
        children: [
          // Map image
          Positioned.fill(
            child: CustomImageWidget(
              imageUrl:
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=900&q=80',
              width: double.infinity,
              height: size.height * 0.50,
              fit: BoxFit.cover,
              semanticLabel:
                  'Aerial city map with streets and neighborhoods for GPS navigation',
            ),
          ),

          // Gradient overlay — deep navy tint for premium feel
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _bg.withAlpha(210),
                    _bg.withAlpha(80),
                    _bg.withAlpha(230),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Ambient teal glow — brand accent
          Positioned(
            left: -30,
            top: 20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primary.withAlpha(55), Colors.transparent],
                ),
              ),
            ),
          ),

          // Secondary glow (right side)
          Positioned(
            right: -40,
            top: 60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.info.withAlpha(30), Colors.transparent],
                ),
              ),
            ),
          ),

          // Route line
          Positioned.fill(child: CustomPaint(painter: _RoutePainter())),

          // Destination pin
          Positioned(right: 80, bottom: 90, child: _DestinationPin()),

          // Partner marker (animated)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bounceAnim,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final x = constraints.maxWidth * _partnerX;
                    final y =
                        constraints.maxHeight * _partnerY + _bounceAnim.value;
                    return Stack(
                      children: [
                        // Ripple
                        Positioned(
                          left: x - 30,
                          top: y - 30,
                          child: AnimatedBuilder(
                            animation: _rippleAnim,
                            builder: (_, __) => Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primary.withOpacity(
                                    (1 - _rippleAnim.value).clamp(0.0, 0.55),
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              transform: Matrix4.identity()
                                ..scale(0.4 + _rippleAnim.value * 0.9),
                            ),
                          ),
                        ),
                        // Glow halo
                        Positioned(
                          left: x - 22,
                          top: y - 22,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withAlpha(130),
                                  blurRadius: 22,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Partner marker
                        Positioned(
                          left: x - 22,
                          top: y - 22,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.primaryDark,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withAlpha(230),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withAlpha(160),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Map credit
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _surface.withAlpha(220),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.primary.withAlpha(60),
                  width: 0.5,
                ),
              ),
              child: Text(
                '© Fixiqo Maps',
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  color: AppTheme.primary.withAlpha(180),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    final statusColor = _statusColor(_currentStatus);
    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _surface.withAlpha(230),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withAlpha(70),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _textMain,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Navigating to Customer',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
              Text(
                widget.job['address'] as String? ?? 'Customer Address',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(fontSize: 11, color: _textSub),
              ),
            ],
          ),
        ),

        // Live status badge
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Transform.scale(
            scale: _currentStatus == JobStatus.enRoute ? _pulseAnim.value : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(28),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: statusColor.withAlpha(110)),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withAlpha(40),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _statusLabel(_currentStatus),
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // BOTTOM PANEL
  // ─────────────────────────────────────────────────────────────────
  Widget _buildBottomPanel(double bottomPadding) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(color: AppTheme.primary.withAlpha(80), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(30),
            blurRadius: 32,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, -2),
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
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withAlpha(60),
                        AppTheme.primary.withAlpha(120),
                        AppTheme.primary.withAlpha(60),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              // ETA + Distance row
              _buildEtaDistanceRow(),
              const SizedBox(height: 20),

              // Status timeline
              _buildStatusTimeline(),
              const SizedBox(height: 20),

              // Customer info
              _buildCustomerCard(),
              const SizedBox(height: 20),

              // Action button
              _buildActionButton(bottomPadding),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ETA + DISTANCE
  // ─────────────────────────────────────────────────────────────────
  Widget _buildEtaDistanceRow() {
    final distance = widget.job['distance'] as String? ?? '2.4 km';
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.schedule_rounded,
            label: 'ETA',
            value: _etaLabel,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.near_me_rounded,
            label: 'Distance',
            value: distance,
            color: _textSub,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.payments_rounded,
            label: 'Payout',
            value: '₹${widget.job['price'] ?? 499}',
            color: AppTheme.warning,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // STATUS TIMELINE
  // ─────────────────────────────────────────────────────────────────
  Widget _buildStatusTimeline() {
    final steps = [
      JobStatus.accepted,
      JobStatus.enRoute,
      JobStatus.arrived,
      JobStatus.inService,
    ];
    final currentIdx = steps.indexOf(_currentStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceElevated,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JOB STATUS',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _labelMuted,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                // Connector line
                final lineIdx = i ~/ 2;
                final filled = lineIdx < currentIdx;
                return Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: filled
                          ? LinearGradient(
                              colors: [
                                AppTheme.primary.withAlpha(180),
                                AppTheme.primary,
                              ],
                            )
                          : null,
                      color: filled ? null : _border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }
              final stepIdx = i ~/ 2;
              final step = steps[stepIdx];
              final isActive = stepIdx == currentIdx;
              final isDone = stepIdx < currentIdx;
              final color = _statusColor(step);

              return AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Transform.scale(
                  scale: isActive ? _pulseAnim.value : 1.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppTheme.primary.withAlpha(25)
                              : isActive
                              ? color.withAlpha(28)
                              : _surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone
                                ? AppTheme.primary.withAlpha(180)
                                : isActive
                                ? color
                                : _borderAccent,
                            width: isActive ? 2 : 1,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: color.withAlpha(90),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          isDone ? Icons.check_rounded : _statusIcon(step),
                          size: 16,
                          color: isDone
                              ? AppTheme.primary
                              : isActive
                              ? color
                              : _labelMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _statusLabel(step),
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isDone
                              ? AppTheme.primary
                              : isActive
                              ? color
                              : _labelMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CUSTOMER CARD
  // ─────────────────────────────────────────────────────────────────
  Widget _buildCustomerCard() {
    final job = widget.job;
    final service = job['service'] as String? ?? 'Service';
    final address = job['address'] as String? ?? 'Customer Address';
    final customerName = job['customerName'] as String? ?? 'Customer';
    final customerAvatar =
        job['customerAvatar'] as String? ??
        'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceElevated,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CUSTOMER',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _labelMuted,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withAlpha(100),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(40),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(customerAvatar),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Call button
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(22),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary.withAlpha(90)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(40),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: GoogleFonts.manrope(fontSize: 12, color: _textSub),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ACTION BUTTON
  // ─────────────────────────────────────────────────────────────────
  Widget _buildActionButton(double bottomPadding) {
    final nextStatus = _nextStatus();
    if (nextStatus == null) {
      // In service — show complete job
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: AppTheme.success.withAlpha(80),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('Complete Job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    final label = _nextActionLabel();
    final color = _statusColor(nextStatus);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(80),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _advanceStatus(nextStatus),
          icon: Icon(_statusIcon(nextStatus), size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  JobStatus? _nextStatus() {
    switch (_currentStatus) {
      case JobStatus.accepted:
        return JobStatus.enRoute;
      case JobStatus.enRoute:
        return JobStatus.arrived;
      case JobStatus.arrived:
        return JobStatus.inService;
      case JobStatus.inService:
        return null;
    }
  }

  String _nextActionLabel() {
    switch (_currentStatus) {
      case JobStatus.accepted:
        return 'Start Navigation';
      case JobStatus.enRoute:
        return 'Mark as Arrived';
      case JobStatus.arrived:
        return 'Start Service';
      case JobStatus.inService:
        return 'Complete Job';
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _surfaceElevated,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.manrope(fontSize: 10, color: _labelMuted),
          ),
        ],
      ),
    );
  }
}

class _DestinationPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _surface.withAlpha(240),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primary.withAlpha(100)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(40),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            'Customer',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.error,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.error.withAlpha(140),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 18),
        ),
        Container(
          width: 2,
          height: 12,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.error.withAlpha(200), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withAlpha(180)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppTheme.primary.withAlpha(50)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(50)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.60);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.50,
      size.width * 0.55,
      size.height * 0.55,
      size.width * 0.72,
      size.height * 0.35,
    );

    // Glow layer
    canvas.drawPath(path, glowPaint);
    // Main route
    canvas.drawPath(path, paint);

    // Dashed overlay
    final dashPath = Path();
    dashPath.moveTo(size.width * 0.25, size.height * 0.60);
    dashPath.cubicTo(
      size.width * 0.35,
      size.height * 0.50,
      size.width * 0.55,
      size.height * 0.55,
      size.width * 0.72,
      size.height * 0.35,
    );
    canvas.drawPath(dashPath, dashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
