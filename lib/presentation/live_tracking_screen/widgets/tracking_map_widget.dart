import '../../../core/app_export.dart';

class TrackingMapWidget extends StatefulWidget {
  final double height;
  final int technicianEta;

  /// Normalised [0..1] X position of the technician marker on the map canvas.
  final double techMarkerX;

  /// Normalised [0..1] Y position of the technician marker on the map canvas.
  final double techMarkerY;

  const TrackingMapWidget({
    required this.height,
    required this.technicianEta,
    this.techMarkerX = 0.35,
    this.techMarkerY = 0.55,
    super.key,
  });

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget>
    with TickerProviderStateMixin {
  late AnimationController _markerBounce;
  late AnimationController _rippleController;
  late Animation<double> _bounceAnim;
  late Animation<double> _rippleAnim;

  // Smoothly animated marker position
  late AnimationController _moveController;
  late Animation<double> _animatedX;
  late Animation<double> _animatedY;

  double _prevX = 0.35;
  double _prevY = 0.55;

  @override
  void initState() {
    super.initState();
    _prevX = widget.techMarkerX;
    _prevY = widget.techMarkerY;

    _markerBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    // Smooth movement controller — 800 ms tween between positions
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animatedX = Tween<double>(begin: _prevX, end: _prevX).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );
    _animatedY = Tween<double>(begin: _prevY, end: _prevY).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );

    _bounceAnim = Tween<double>(
      begin: 0.0,
      end: -6.0,
    ).animate(CurvedAnimation(parent: _markerBounce, curve: Curves.easeInOut));
    _rippleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(TrackingMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newX = widget.techMarkerX;
    final newY = widget.techMarkerY;

    if (newX != oldWidget.techMarkerX || newY != oldWidget.techMarkerY) {
      // Capture current animated value as the new start point
      final startX = _animatedX.value;
      final startY = _animatedY.value;

      _animatedX = Tween<double>(begin: startX, end: newX).animate(
        CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
      );
      _animatedY = Tween<double>(begin: startY, end: newY).animate(
        CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
      );

      _moveController.forward(from: 0.0);
      _prevX = newX;
      _prevY = newY;
    }
  }

  @override
  void dispose() {
    _markerBounce.dispose();
    _rippleController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height == double.infinity ? null : widget.height,
      child: Stack(
        children: [
          // Map background image
          Positioned.fill(
            child: CustomImageWidget(
              imageUrl:
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80',
              width: double.infinity,
              height: widget.height,
              fit: BoxFit.cover,
              semanticLabel:
                  'Aerial view city map with streets and neighborhoods for GPS navigation',
            ),
          ),

          // Dark cinematic overlay — top fade
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC080E1A),
                    Color(0x44080E1A),
                    Color(0xDD080E1A),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Teal ambient glow on map
          Positioned(
            left: -30,
            top: 20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00C896).withAlpha(38),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Route line (simulated)
          Positioned.fill(child: CustomPaint(painter: _RoutePainter())),

          // Home pin (destination)
          Positioned(right: 80, bottom: 80, child: _HomePinMarker()),

          // Technician moving marker — driven by live location
          AnimatedBuilder(
            animation: Listenable.merge([_bounceAnim, _animatedX, _animatedY]),
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final x = constraints.maxWidth * _animatedX.value;
                  final y =
                      constraints.maxHeight * _animatedY.value +
                      _bounceAnim.value;
                  return Stack(
                    children: [
                      // Outer ripple ring
                      Positioned(
                        left: x - 30,
                        top: y - 30,
                        child: AnimatedBuilder(
                          animation: _rippleAnim,
                          builder: (context, _) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF00C896).withOpacity(
                                    (1 - _rippleAnim.value).clamp(0.0, 0.6),
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              transform: Matrix4.identity()
                                ..scale(0.4 + _rippleAnim.value * 0.9),
                            );
                          },
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
                                color: const Color(0xFF00C896).withAlpha(128),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Technician marker
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
                              colors: [Color(0xFF00C896), Color(0xFF009B74)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(230),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00C896).withAlpha(153),
                                blurRadius: 14,
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

          // Map attribution — dark styled
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A).withAlpha(217),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF00C896).withAlpha(51),
                  width: 0.5,
                ),
              ),
              child: const Text(
                '© Fixiqo Maps',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF64A89A),
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePinMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF6B35), Color(0xFFE84E1B)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(230), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withAlpha(140),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 18),
        ),
        Container(
          width: 2,
          height: 10,
          color: const Color(0xFFFF6B35).withAlpha(180),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withAlpha(100),
            shape: BoxShape.circle,
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
      ..color = const Color(0xFF00C896).withAlpha(120)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = const Color(0xFF00C896).withAlpha(60)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.35, size.height * 0.55)
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.45,
        size.width * 0.65,
        size.height * 0.40,
        size.width - 80,
        size.height - 80,
      );

    canvas.drawPath(path, paint);

    // Dashed shadow
    final dashPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.55)
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.50,
        size.width * 0.60,
        size.height * 0.45,
        size.width - 80,
        size.height - 80,
      );
    canvas.drawPath(dashPath, dashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
