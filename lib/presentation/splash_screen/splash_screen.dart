import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _iconsController;
  late AnimationController _pulseController;
  late AnimationController _exitController;

  late Animation<double> _bgGradientAnim;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _iconsOpacity;
  late Animation<double> _pulseAnim;
  late Animation<double> _exitOpacity;

  final List<Map<String, dynamic>> _services = [
{'icon': Icons.plumbing_rounded, 'label': 'Plumbing', 'delay': 0.0},
{'icon': Icons.electrical_services_rounded, 'label': 'Electrical', 'delay': 0.12},
{'icon': Icons.ac_unit_rounded, 'label': 'AC Repair', 'delay': 0.24},
{'icon': Icons.construction_rounded, 'label': 'Carpentry', 'delay': 0.36},
{'icon': Icons.cleaning_services_rounded, 'label': 'Cleaning', 'delay': 0.48},
{'icon': Icons.pest_control_rounded, 'label': 'Pest Control', 'delay': 0.60},
];

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _iconsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bgGradientAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _iconsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconsController, curve: Curves.easeOut),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _iconsController.forward();

    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      await _exitController.forward();
      if (mounted) {
        context.go(AppRoutes.signUpLoginScreen);
      }
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _iconsController.dispose();
    _pulseController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: FadeTransition(
        opacity: _exitOpacity,
        child: AnimatedBuilder(
          animation: _bgGradientAnim,
          builder: (context, child) {
            final t = _bgGradientAnim.value;
            return Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      const Color(0xFF00D4A8),
                      const Color(0xFF00B894),
                      t,
                    )!,
                    Color.lerp(
                      const Color(0xFF00C896),
                      const Color(0xFF009B74),
                      t,
                    )!,
                    Color.lerp(
                      const Color(0xFF0097A7),
                      const Color(0xFF00838F),
                      t,
                    )!,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: child,
            );
          },
          child: Stack(
            children: [
              // Decorative circles background
              Positioned(
                top: -size.height * 0.12,
                right: -size.width * 0.2,
                child: _DecorativeCircle(
                  size: size.width * 0.7,
                  color: Colors.white.withAlpha(18),
                ),
              ),
              Positioned(
                bottom: -size.height * 0.08,
                left: -size.width * 0.25,
                child: _DecorativeCircle(
                  size: size.width * 0.8,
                  color: Colors.white.withAlpha(13),
                ),
              ),
              Positioned(
                top: size.height * 0.35,
                left: -size.width * 0.1,
                child: _DecorativeCircle(
                  size: size.width * 0.4,
                  color: Colors.white.withAlpha(10),
                ),
              ),

              // Animated dot grid pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _DotGridPainter(),
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Logo + Brand name block
                    SlideTransition(
                      position: _logoSlide,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Column(
                            children: [
                              // Logo container
                              AnimatedBuilder(
                                animation: _pulseAnim,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnim.value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(40),
                                        blurRadius: 32,
                                        offset: const Offset(0, 12),
                                        spreadRadius: -4,
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withAlpha(60),
                                        blurRadius: 0,
                                        offset: const Offset(0, -2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          Icons.home_repair_service_rounded,
                                          size: 44,
                                          color: AppTheme.primary,
                                        ),
                                        Positioned(
                                          bottom: 18,
                                          right: 18,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF6B35),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.bolt_rounded,
                                              size: 9,
                                              color: Colors.white,
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
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Brand name + tagline
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Fix',
                                    style: GoogleFonts.manrope(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -1.5,
                                      height: 1.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'iqo',
                                    style: GoogleFonts.manrope(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white.withAlpha(220),
                                      letterSpacing: -1.5,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white.withAlpha(60),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Emergency Home Services',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withAlpha(230),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Trusted professionals,\nat your doorstep in minutes',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withAlpha(200),
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Service icons row
                    FadeTransition(
                      opacity: _iconsOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _services.asMap().entries.map((entry) {
                            final i = entry.key;
                            final service = entry.value;
                            return _AnimatedServiceChip(
                              icon: service['icon'] as IconData,
                              label: service['label'] as String,
                              delay: Duration(
                                milliseconds: ((service['delay'] as double) * 600).toInt(),
                              ),
                              parentController: _iconsController,
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Loading indicator
                    FadeTransition(
                      opacity: _iconsOpacity,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.white.withAlpha(40),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                minHeight: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Getting things ready...',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(160),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedServiceChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final Duration delay;
  final AnimationController parentController;

  const _AnimatedServiceChip({
    required this.icon,
    required this.label,
    required this.delay,
    required this.parentController,
  });

  @override
  State<_AnimatedServiceChip> createState() => _AnimatedServiceChipState();
}

class _AnimatedServiceChipState extends State<_AnimatedServiceChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    widget.parentController.addStatusListener((status) {
      if (status == AnimationStatus.forward ||
          status == AnimationStatus.completed) {
        Future.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withAlpha(60),
                  width: 1,
                ),
              ),
              child: Icon(
                widget.icon,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.label,
              style: GoogleFonts.manrope(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(190),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    const dotRadius = 1.5;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => false;
}