import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class BookingSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingSummaryWidget({required this.booking, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.secondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    booking['id'] as String,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _SummaryRow(
              icon: Icons.build_rounded,
              label: 'Service',
              value: booking['service'] as String,
            ),
            const SizedBox(height: 10),
            _SummaryRow(
              icon: Icons.report_problem_outlined,
              label: 'Issue',
              value: booking['issue'] as String,
            ),
            const SizedBox(height: 10),
            _SummaryRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: booking['address'] as String,
            ),
            const SizedBox(height: 14),

            Container(height: 1, color: AppTheme.outlineVariantLight),
            const SizedBox(height: 14),

            // Price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upfront Price',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '\$${booking['price']}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.secondary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withAlpha(26),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'No hidden fees',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // 30-min guarantee badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00C896), Color(0xFF009B74)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '30-min',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Guarantee',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 9,
                          color: Colors.white.withAlpha(217),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariantLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
