import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class SubscriptionPromoWidget extends StatelessWidget {
  const SubscriptionPromoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF2D2D50)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withAlpha(64),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(51),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppTheme.primary.withAlpha(102)),
                  ),
                  child: Text(
                    'MONTHLY PLAN',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Home Care\nSubscription',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unlimited check-ups, priority\nbooking & 20% off all services',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(166),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text(
                      '\$29',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      '/month',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: Colors.white.withAlpha(153),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Plan features icons
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _PromoFeature(icon: Icons.shield_rounded, label: 'Priority'),
              const SizedBox(height: 16),
              _PromoFeature(icon: Icons.percent_rounded, label: '20% Off'),
              const SizedBox(height: 16),
              _PromoFeature(icon: Icons.bolt_rounded, label: '30-min'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoFeature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PromoFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(38),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha(179),
          ),
        ),
      ],
    );
  }
}
