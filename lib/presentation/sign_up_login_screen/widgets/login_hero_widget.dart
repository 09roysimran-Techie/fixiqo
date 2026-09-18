import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class LoginHeroWidget extends StatefulWidget {
  const LoginHeroWidget({super.key});

  @override
  State<LoginHeroWidget> createState() => _LoginHeroWidgetState();
}

class _LoginHeroWidgetState extends State<LoginHeroWidget>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _chipsController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  late Animation<double> _bgAnim;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _chipsOpacity;
  late Animation<double> _pulseAnim;
  late Animation<double> _floatAnim;

  final List<Map<String, dynamic>> _services = [
    {'icon': Icons.plumbing_rounded, 'label': 'Plumbing', 'delay': 0.0},
    {
      'icon': Icons.electrical_services_rounded,
      'label': 'Electrical',
      'delay': 0.12,
    },
    {'icon': Icons.ac_unit_rounded, 'label': 'AC Repair', 'delay': 0.24},
    {'icon': Icons.construction_rounded, 'label': 'Carpentry', 'delay': 0.36},
    {
      'icon': Icons.cleaning_services_rounded,
      'label': 'Cleaning',
      'delay': 0.48,
    },
    {'icon': Icons.pest_control_rounded, 'label': 'Pest', 'delay': 0.60},
  ];

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _chipsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _bgAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
        );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _chipsOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _chipsController, curve: Curves.easeOut));

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _chipsController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _chipsController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: AnimatedBuilder(
        animation: _bgAnim,
        builder: (context, child) {
          final t = _bgAnim.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFFE8F5F1),
                    const Color(0xFFDFF2EC),
                    t,
                  )!,
                  Color.lerp(
                    const Color(0xFFF0F9F6),
                    const Color(0xFFE6F7F2),
                    t,
                  )!,
                  Color.lerp(
                    const Color(0xFF00C896).withAlpha(40),
                    const Color(0xFF009B74).withAlpha(30),
                    t,
                  )!,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -size.height * 0.1,
              right: -size.width * 0.2,
              child: _DecorativeCircle(
                size: size.width * 0.75,
                color: AppTheme.primary.withAlpha(20),
              ),
            ),
            Positioned(
              bottom: size.height * 0.25,
              left: -size.width * 0.3,
              child: _DecorativeCircle(
                size: size.width * 0.85,
                color: AppTheme.primary.withAlpha(10),
              ),
            ),
            Positioned(
              top: size.height * 0.3,
              right: -size.width * 0.1,
              child: _DecorativeCircle(
                size: size.width * 0.45,
                color: AppTheme.primary.withAlpha(15),
              ),
            ),

            // Dot grid
            Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

            // Floating accent orb
            AnimatedBuilder(
              animation: _floatAnim,
              builder: (context, child) {
                return Positioned(
                  top: size.height * 0.18 + _floatAnim.value,
                  left: size.width * 0.08,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(180),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.primary.withAlpha(60),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.home_repair_service_rounded,
                      size: 28,
                      color: AppTheme.primary,
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _floatAnim,
              builder: (context, child) {
                return Positioned(
                  top: size.height * 0.32 - _floatAnim.value,
                  right: size.width * 0.07,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(180),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withAlpha(60),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withAlpha(25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      size: 24,
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
                );
              },
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo block
                  SlideTransition(
                    position: _logoSlide,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnim.value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withAlpha(60),
                                  blurRadius: 40,
                                  offset: const Offset(0, 12),
                                  spreadRadius: -4,
                                ),
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.home_repair_service_rounded,
                                  size: 48,
                                  color: AppTheme.primary,
                                ),
                                Positioned(
                                  bottom: 20,
                                  right: 20,
                                  child: Container(
                                    width: 18,
                                    height: 18,
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
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

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
                                    fontSize: 44,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A1A2E),
                                    letterSpacing: -1.5,
                                    height: 1.0,
                                  ),
                                ),
                                TextSpan(
                                  text: 'iqo',
                                  style: GoogleFonts.manrope(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w300,
                                    color: AppTheme.primary,
                                    letterSpacing: -1.5,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: AppTheme.primary.withAlpha(60),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Emergency Home Services',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryDark,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Trusted professionals,\nat your doorstep in minutes',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF475569),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Service chips row
                  FadeTransition(
                    opacity: _chipsOpacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _services.asMap().entries.map((entry) {
                          final service = entry.value;
                          return _AnimatedServiceChip(
                            icon: service['icon'] as IconData,
                            label: service['label'] as String,
                            delay: Duration(
                              milliseconds: ((service['delay'] as double) * 600)
                                  .toInt(),
                            ),
                            parentController: _chipsController,
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Space for bottom sheet
                  const SizedBox(height: 240),
                ],
              ),
            ),
          ],
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
    _scale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primary.withAlpha(50),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(widget.icon, size: 22, color: AppTheme.primary),
            ),
            const SizedBox(height: 5),
            Text(
              widget.label,
              style: GoogleFonts.manrope(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
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
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00C896).withAlpha(25)
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
