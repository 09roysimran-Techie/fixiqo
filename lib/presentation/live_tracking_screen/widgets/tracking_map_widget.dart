import '../../../core/app_export.dart';

class TrackingMapWidget extends StatefulWidget {
  final double height;
  final int technicianEta;

  const TrackingMapWidget({
    required this.height,
    required this.technicianEta,
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

  // Simulated technician position (normalized 0.0–1.0 within the map area)
  final double _techX = 0.35;
  final double _techY = 0.55;

  @override
  void initState() {
    super.initState();
    _markerBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _bounceAnim = Tween<double>(
      begin: 0.0,
      end: -6.0,
    ).animate(CurvedAnimation(parent: _markerBounce, curve: Curves.easeInOut));
    _rippleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _markerBounce.dispose();
    _rippleController.dispose();
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

          // Green tint overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primary.withAlpha(20),
                    Colors.transparent,
                    Colors.black.withAlpha(38),
                  ],
                ),
              ),
            ),
          ),

          // Route line (simulated)
          Positioned.fill(child: CustomPaint(painter: _RoutePainter())),

          // Home pin (destination)
          Positioned(right: 80, bottom: 80, child: _HomePinMarker()),

          // Technician moving marker
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bounceAnim,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final x = constraints.maxWidth * _techX;
                    final y =
                        constraints.maxHeight * _techY + _bounceAnim.value;
                    return Stack(
                      children: [
                        // Ripple ring
                        Positioned(
                          left: x - 24,
                          top: y - 24,
                          child: AnimatedBuilder(
                            animation: _rippleAnim,
                            builder: (context, _) {
                              return Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primary.withOpacity(
                                      (1 - _rippleAnim.value).clamp(0.0, 1.0),
                                    ),
                                    width: 2,
                                  ),
                                ),
                                transform: Matrix4.identity()
                                  ..scale(0.5 + _rippleAnim.value * 0.8),
                              );
                            },
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
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withAlpha(102),
                                  blurRadius: 12,
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

          // Map attribution
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(217),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '© Fixiqo Maps',
                style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
        ),
        Container(width: 2, height: 12, color: AppTheme.secondary),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.secondary,
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
      ..color = AppTheme.primary.withAlpha(179)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.35, size.height * 0.55);
    path.cubicTo(
      size.width * 0.45,
      size.height * 0.45,
      size.width * 0.60,
      size.height * 0.55,
      size.width * 0.80,
      size.height * 0.30,
    );

    // Dashed path effect
    final dashPaint = Paint()
      ..color = AppTheme.primary.withAlpha(128)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
