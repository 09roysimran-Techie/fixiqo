import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/home_app_bar_widget.dart';
import './widgets/service_category_grid_widget.dart';
import './widgets/specialist_card_widget.dart';
import './widgets/subscription_promo_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late AnimationController _bgController;
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  late Animation<double> _bgAnim;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _pulseAnim;

  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _bgAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    Future.delayed(const Duration(milliseconds: 80), () {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bgController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgAnim, _pulseAnim]),
        builder: (context, child) {
          final t = _bgAnim.value;
          return Stack(
            children: [
              // Deep background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF080E1A),
                        const Color(0xFF0B1220),
                        t,
                      )!,
                      Color.lerp(
                        const Color(0xFF0D1829),
                        const Color(0xFF091525),
                        t,
                      )!,
                      Color.lerp(
                        const Color(0xFF0A1F35),
                        const Color(0xFF071830),
                        t,
                      )!,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Ambient glow top-right
              Positioned(
                top: -size.height * 0.1,
                right: -size.width * 0.15,
                child: Container(
                  width: size.width * 0.75,
                  height: size.width * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color.lerp(
                          const Color(0xFF00C896).withAlpha(35),
                          const Color(0xFF00C896).withAlpha(20),
                          t,
                        )!,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Ambient glow bottom-left
              Positioned(
                bottom: size.height * 0.2,
                left: -size.width * 0.25,
                child: Container(
                  width: size.width * 0.65,
                  height: size.width * 0.65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color.lerp(
                          const Color(0xFFFF6B35).withAlpha(20),
                          const Color(0xFFFF6B35).withAlpha(10),
                          t,
                        )!,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle noise texture
              Positioned.fill(
                child: CustomPaint(painter: _NoiseTexturePainter()),
              ),
              child!,
            ],
          );
        },
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // App bar
              FadeTransition(
                opacity: _fadeIn,
                child: HomeAppBarWidget(
                  greeting: _getGreeting(),
                  userName: 'Marcus',
                  avatarUrl:
                      'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg',
                  onSearchTap: () {},
                  onNotificationTap: () {},
                  scrollOffset: _scrollOffset,
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primary,
                  backgroundColor: const Color(0xFF0D1829),
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 800));
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Hero section
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _fadeIn,
                          child: SlideTransition(
                            position: _slideUp,
                            child: _HeroSection(pulseAnim: _pulseAnim),
                          ),
                        ),
                      ),

                      // Search bar
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _fadeIn,
                          child: SlideTransition(
                            position: _slideUp,
                            child: const _SearchBar(),
                          ),
                        ),
                      ),

                      // Live status banner
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _fadeIn,
                          child: AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (context, child) =>
                                _LiveStatusBanner(pulseValue: _pulseAnim.value),
                          ),
                        ),
                      ),

                      // Services section header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: _SectionHeader(
                            title: 'Services',
                            subtitle: 'What do you need fixed?',
                          ),
                        ),
                      ),

                      // Service category grid
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ServiceCategoryGridWidget(isTablet: isTablet),
                        ),
                      ),

                      // Specialists section header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                          child: _SectionHeader(
                            title: 'Nearby Specialists',
                            subtitle: 'Verified pros, ready now',
                            actionLabel: 'See All',
                            onAction: () {},
                          ),
                        ),
                      ),

                      // Specialist cards
                      SliverToBoxAdapter(
                        child: isTablet
                            ? _buildTabletSpecialistGrid()
                            : _buildPhoneSpecialistScroll(),
                      ),

                      // Stats strip
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                          child: const _StatsStrip(),
                        ),
                      ),

                      // Subscription promo
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: const SubscriptionPromoWidget(),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: SizedBox(height: 120 + bottomPadding),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneSpecialistScroll() {
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _specialists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final s = _specialists[i];
          return SpecialistCardWidget(
            specialist: s,
            onBookNow: () => context.push(
              AppRoutes.preCheckoutScreen,
              extra: {
                'service': '${s['specialty']} Service',
                'technician': s['name'],
                'basePrice': s['price'],
                'convenienceFee': 29,
                'gst': ((s['price'] as num) * 0.18).round(),
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabletSpecialistGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemCount: _specialists.length,
        itemBuilder: (context, i) {
          final s = _specialists[i];
          return SpecialistCardWidget(
            specialist: s,
            onBookNow: () => context.push(
              AppRoutes.preCheckoutScreen,
              extra: {
                'service': '${s['specialty']} Service',
                'technician': s['name'],
                'basePrice': s['price'],
                'convenienceFee': 29,
                'gst': ((s['price'] as num) * 0.18).round(),
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Hero Section ────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _HeroSection({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow tag
          Row(
            children: [
              AnimatedBuilder(
                animation: pulseAnim,
                builder: (context, child) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00C896),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF00C896,
                        ).withAlpha((pulseAnim.value * 120).toInt()),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '47 pros available near you',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF00C896),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Main headline
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Home repairs,\n',
                  style: GoogleFonts.dmSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'done right.',
                  style: GoogleFonts.dmSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.transparent,
                    height: 1.1,
                    letterSpacing: -0.5,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFF00C896), Color(0xFF00A8FF)],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Certified technicians at your door in under 30 minutes.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withAlpha(120),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(22), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search_rounded,
                size: 20,
                color: Colors.white.withAlpha(100),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search services, specialists...',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white.withAlpha(80),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C896).withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF00C896).withAlpha(60),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 13,
                      color: const Color(0xFF00C896),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Filter',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00C896),
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

// ─── Live Status Banner ───────────────────────────────────────────────────────
class _LiveStatusBanner extends StatelessWidget {
  final double pulseValue;
  const _LiveStatusBanner({required this.pulseValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFFFF6B35).withAlpha(18),
              const Color(0xFFFF6B35).withAlpha(8),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFF6B35).withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Color(0xFFFF6B35),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Response Active',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Avg. arrival time: 18 min · 24/7 support',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.white.withAlpha(110),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withAlpha(30),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF6B35),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFFF6B35,
                          ).withAlpha((pulseValue * 150).toInt()),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'LIVE',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF6B35),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.white.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white.withAlpha(20), width: 1),
              ),
              child: Text(
                actionLabel!,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Stats Strip ──────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(14), width: 1),
      ),
      child: Row(
        children: [
          _StatItem(value: '50K+', label: 'Jobs Done'),
          _StatDivider(),
          _StatItem(value: '4.9★', label: 'Avg Rating'),
          _StatDivider(),
          _StatItem(value: '18 min', label: 'Avg Arrival'),
          _StatDivider(),
          _StatItem(value: '100%', label: 'Verified'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: Colors.white.withAlpha(90),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: Colors.white.withAlpha(18));
  }
}

// ─── Noise Texture Painter ────────────────────────────────────────────────────
class _NoiseTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    const spacing = 32.0;
    const dotRadius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Mock specialist data ─────────────────────────────────────────────────────
final List<Map<String, dynamic>> _specialists = [
  {
    'name': 'Rahim Uddin',
    'specialty': 'Electrician',
    'rating': 4.9,
    'reviews': 142,
    'price': 499,
    'eta': '12 min',
    'distance': '1.2 km',
    'imageUrl':
        'https://img.rocket.new/generatedImages/rocket_gen_img_193df7de3-1782816308433.png',
    'semanticLabel':
        'Male electrician in orange and blue uniform with hard hat, arms crossed, standing in front of electrical panels',
    'available': true,
    'badge': 'Top Rated',
  },
  {
    'name': 'Carlos Mendes',
    'specialty': 'Plumbing',
    'rating': 4.7,
    'reviews': 98,
    'price': 399,
    'eta': '18 min',
    'distance': '2.1 km',
    'imageUrl':
        'https://img.rocket.new/generatedImages/rocket_gen_img_11c8c04d2-1772209925689.png',
    'semanticLabel':
        'Male plumber in blue overalls holding a wrench, smiling professionally',
    'available': true,
    'badge': 'Fast Response',
  },
  {
    'name': 'Priya Sharma',
    'specialty': 'AC Repair',
    'rating': 4.8,
    'reviews': 76,
    'price': 549,
    'eta': '22 min',
    'distance': '3.4 km',
    'imageUrl':
        'https://img.rocket.new/generatedImages/rocket_gen_img_1f8e93ef6-1773013247993.png',
    'semanticLabel':
        'Female HVAC technician in grey uniform inspecting an air conditioning unit',
    'available': true,
    'badge': null,
  },
  {
    'name': 'James Okafor',
    'specialty': 'Carpentry',
    'rating': 4.6,
    'reviews': 54,
    'price': 449,
    'eta': '30 min',
    'distance': '4.1 km',
    'imageUrl':
        'https://img.rocket.new/generatedImages/rocket_gen_img_1a993cbd1-1772249183631.png',
    'semanticLabel':
        'Male carpenter in workshop apron holding woodworking tools, smiling',
    'available': false,
    'badge': null,
  },
];
