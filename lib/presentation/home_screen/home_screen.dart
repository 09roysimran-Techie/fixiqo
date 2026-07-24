import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/home_app_bar_widget.dart';
import './widgets/service_category_grid_widget.dart';
import './widgets/specialist_card_widget.dart';
import './widgets/subscription_promo_widget.dart';

// TODO: Replace with Riverpod/Bloc for production state management

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HomeAppBarWidget(
              greeting: _getGreeting(),
              userName: 'Marcus',
              avatarUrl:
                  'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg',
              onSearchTap: () {},
              onNotificationTap: () {},
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Text(
                          'Find Trusted Home\nServices',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: AppTheme.secondary,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: ServiceCategoryGridWidget(isTablet: isTablet),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Service Specialists',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppTheme.secondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: isTablet
                          ? _buildTabletSpecialistGrid()
                          : _buildPhoneSpecialistScroll(),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
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
    );
  }

  Widget _buildPhoneSpecialistScroll() {
    return SizedBox(
      height: 280,
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
              AppRoutes.paymentScreen,
              extra: {
                'service': '${s['specialty']} Service',
                'technician': s['name'],
                'date': 'Today, 3:00 PM',
                'address': '42, Koramangala, Bengaluru',
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
              AppRoutes.paymentScreen,
              extra: {
                'service': '${s['specialty']} Service',
                'technician': s['name'],
                'date': 'Today, 3:00 PM',
                'address': '42, Koramangala, Bengaluru',
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

// Mock specialist data
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
    'name': 'David Okafor',
    'specialty': 'Painting',
    'rating': 4.6,
    'reviews': 55,
    'price': 299,
    'eta': '35 min',
    'distance': '4.8 km',
    'imageUrl':
        'https://img.rocket.new/generatedImages/rocket_gen_img_1caa3c922-1767074248361.png',
    'semanticLabel':
        'Male painter in white overalls holding a roller brush, standing next to a freshly painted wall',
    'available': false,
    'badge': null,
  },
];
