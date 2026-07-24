import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ActiveJobMapWidget extends StatefulWidget {
  final Map<String, dynamic> activeJob;
  final VoidCallback onCompleteJob;

  const ActiveJobMapWidget({
    super.key,
    required this.activeJob,
    required this.onCompleteJob,
  });

  @override
  State<ActiveJobMapWidget> createState() => _ActiveJobMapWidgetState();
}

class _ActiveJobMapWidgetState extends State<ActiveJobMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map placeholder with route visualization
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  // Map background
                  Container(
                    color: const Color(0xFFE8F0E9),
                    child: CustomPaint(
                      painter: _MapGridPainter(),
                      size: Size.infinite,
                    ),
                  ),
                  // Route line
                  CustomPaint(painter: _RoutePainter(), size: Size.infinite),
                  // Destination pin
                  Positioned(
                    right: 80,
                    top: 55,
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.error.withAlpha(80),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        Container(width: 2, height: 10, color: AppTheme.error),
                      ],
                    ),
                  ),
                  // Technician marker (animated)
                  Positioned(
                    left: 60,
                    bottom: 55,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnim.value,
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withAlpha(100),
                                  blurRadius: 14,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.engineering_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 10,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ETA badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.navigation_rounded,
                            size: 12,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${widget.activeJob['eta']} away',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Navigate button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withAlpha(80),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Navigate',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Job details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.activeJob['service'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 13,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  widget.activeJob['address'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${widget.activeJob['price']}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Status steps
                _buildStatusRow(context),
                const SizedBox(height: 14),
                // Action buttons
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.phone_rounded,
                      label: 'Call',
                      color: AppTheme.info,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Chat',
                      color: AppTheme.secondary,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onCompleteJob,
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Mark Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context) {
    final steps = ['Accepted', 'En Route', 'Arrived', 'Fixed'];
    final currentStep = widget.activeJob['statusStep'] as int;

    return Row(
      children: List.generate(steps.length, (i) {
        final isDone = i < currentStep;
        final isActive = i == currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppTheme.primary
                            : isActive
                            ? AppTheme.primaryContainer
                            : AppTheme.outlineLight,
                        shape: BoxShape.circle,
                        border: isActive
                            ? Border.all(color: AppTheme.primary, width: 2)
                            : null,
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Colors.white,
                            )
                          : isActive
                          ? Container(
                              margin: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isActive
                            ? AppTheme.primary
                            : isDone
                            ? AppTheme.secondary
                            : const Color(0xFF94A3B8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Container(
                  height: 2,
                  width: 12,
                  color: i < currentStep
                      ? AppTheme.primary
                      : AppTheme.outlineLight,
                  margin: const EdgeInsets.only(bottom: 18),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for map grid background
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E6D5)
      ..strokeWidth = 1;

    // Horizontal roads
    for (double y = 40; y < size.height; y += 55) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical roads
    for (double x = 50; x < size.width; x += 65) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Blocks
    final blockPaint = Paint()..color = const Color(0xFFCCDECD);
    canvas.drawRect(const Rect.fromLTWH(55, 45, 60, 50), blockPaint);
    canvas.drawRect(const Rect.fromLTWH(120, 45, 55, 50), blockPaint);
    canvas.drawRect(const Rect.fromLTWH(180, 45, 65, 50), blockPaint);
    canvas.drawRect(const Rect.fromLTWH(55, 100, 60, 50), blockPaint);
    canvas.drawRect(const Rect.fromLTWH(120, 100, 55, 50), blockPaint);
    canvas.drawRect(const Rect.fromLTWH(180, 100, 65, 50), blockPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for route line
class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(75, size.height - 60);
    path.lineTo(75, size.height - 100);
    path.lineTo(size.width - 95, size.height - 100);
    path.lineTo(size.width - 95, 70);

    canvas.drawPath(path, paint);

    // Dashed overlay for style
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(120)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, dashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
