import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../services/user_role_service.dart';
import '../../theme/app_theme.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isLoading = false;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _selectCustomer() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await UserRoleService.instance.saveAsCustomer();
      if (mounted) context.go(AppRoutes.homeScreen);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save role. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectPartner() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await UserRoleService.instance.saveAsPartner();
      if (mounted) context.go(AppRoutes.partnerHomeScreen);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save role. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0F9F6),
                  Color(0xFFE8F5F1),
                  Color(0xFFF5F7FA),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withAlpha(10),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      // Logo / brand
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primary.withAlpha(80),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withAlpha(30),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_repair_service_rounded,
                          color: AppTheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to Fixiqo',
                        style: GoogleFonts.manrope(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A2E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How would you like to continue?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Customer card
                      _RoleCard(
                        icon: Icons.person_rounded,
                        title: 'I\'m a Customer',
                        subtitle: 'Book trusted home professionals',
                        features: const [
                          'Browse & book services',
                          'Live job tracking',
                          'Membership plans',
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00C896), Color(0xFF009B74)],
                        ),
                        accentColor: AppTheme.primary,
                        isLoading: _isLoading,
                        onTap: _selectCustomer,
                      ),
                      const SizedBox(height: 16),
                      // Partner card
                      _RoleCard(
                        icon: Icons.engineering_rounded,
                        title: 'I\'m a Partner',
                        subtitle: 'Manage jobs & grow your business',
                        features: const [
                          'Accept & manage jobs',
                          'Track your earnings',
                          'Build your ratings',
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        ),
                        accentColor: const Color(0xFF3B82F6),
                        isLoading: _isLoading,
                        onTap: _selectPartner,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'You can switch roles anytime from your profile',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Full-screen loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(30),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> features;
  final LinearGradient gradient;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isLoading;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.gradient,
    required this.accentColor,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
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
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.accentColor.withAlpha(40),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withAlpha(25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...widget.features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: widget.accentColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              f,
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: widget.accentColor.withAlpha(180),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
