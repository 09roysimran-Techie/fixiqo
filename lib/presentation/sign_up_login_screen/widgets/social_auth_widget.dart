import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class SocialAuthWidget extends StatefulWidget {
  final VoidCallback onSignedIn;

  const SocialAuthWidget({required this.onSignedIn, super.key});

  @override
  State<SocialAuthWidget> createState() => _SocialAuthWidgetState();
}

class _SocialAuthWidgetState extends State<SocialAuthWidget>
    with SingleTickerProviderStateMixin {
  bool _googleLoading = false;
  bool _appleLoading = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _googleLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _googleLoading = false);
      widget.onSignedIn();
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _appleLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _appleLoading = false);
      widget.onSignedIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border(
              top: BorderSide(color: AppTheme.outlineLight, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 40,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineLight,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 22),

              // Header text
              Text(
                'Get Started',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to book trusted home professionals',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Demo info chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primary.withAlpha(60),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo: tap "Continue with Google" to sign in',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Google button
              _AuthButton(
                label: 'Continue with Google',
                iconWidget: _GoogleIcon(),
                isLoading: _googleLoading,
                onTap: _handleGoogleSignIn,
                backgroundColor: AppTheme.primary,
                textColor: Colors.white,
                borderColor: Colors.transparent,
              ),
              const SizedBox(height: 12),

              // Apple button
              _AuthButton(
                label: 'Continue with Apple',
                iconWidget: const Icon(
                  Icons.apple_rounded,
                  size: 22,
                  color: Color(0xFF1A1A2E),
                ),
                isLoading: _appleLoading,
                onTap: _handleAppleSignIn,
                backgroundColor: AppTheme.surfaceVariantLight,
                textColor: const Color(0xFF1A1A2E),
                borderColor: AppTheme.outlineLight,
              ),
              const SizedBox(height: 18),

              // Divider with text
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: AppTheme.outlineLight),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'secure & private',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: AppTheme.outlineLight),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Terms
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primary,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primary,
                      ),
                    ),
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

class _AuthButton extends StatefulWidget {
  final String label;
  final Widget iconWidget;
  final bool isLoading;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _AuthButton({
    required this.label,
    required this.iconWidget,
    required this.isLoading,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.reverse(),
      onTapUp: (_) {
        _pressController.forward();
        widget.onTap();
      },
      onTapCancel: () => _pressController.forward(),
      child: ScaleTransition(
        scale: _pressController,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(30),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.isLoading
              ? Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.textColor,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.iconWidget,
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: widget.textColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    paint.color = Colors.white.withAlpha(220);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      -1.0,
      2.0,
      false,
      paint,
    );
    paint.color = Colors.white.withAlpha(180);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      1.0,
      1.5,
      false,
      paint,
    );
    paint.color = Colors.white.withAlpha(200);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      2.5,
      1.0,
      false,
      paint,
    );
    paint.color = Colors.white.withAlpha(210);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      3.5,
      0.8,
      false,
      paint,
    );

    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withAlpha(220)
      ..strokeWidth = 2.2;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(size.width - 2, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
