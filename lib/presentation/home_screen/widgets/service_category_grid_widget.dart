import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ServiceCategoryGridWidget extends StatefulWidget {
  final bool isTablet;

  const ServiceCategoryGridWidget({this.isTablet = false, super.key});

  @override
  State<ServiceCategoryGridWidget> createState() =>
      _ServiceCategoryGridWidgetState();
}

class _ServiceCategoryGridWidgetState extends State<ServiceCategoryGridWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final List<Animation<double>> _itemAnimations = [];
  int _selectedIndex = -1;

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'Cleaning',
      'icon': Icons.cleaning_services_rounded,
      'color': Color(0xFF3B82F6),
    },
    {
      'label': 'Plumbing',
      'icon': Icons.plumbing_rounded,
      'color': Color(0xFF8B5CF6),
    },
    {
      'label': 'Electrical',
      'icon': Icons.electrical_services_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'label': 'AC Repair',
      'icon': Icons.ac_unit_rounded,
      'color': Color(0xFF06B6D4),
    },
    {
      'label': 'Painting',
      'icon': Icons.format_paint_rounded,
      'color': Color(0xFFEC4899),
    },
    {
      'label': 'Repair',
      'icon': Icons.construction_rounded,
      'color': Color(0xFFEF4444),
    },
    {
      'label': 'Bathroom',
      'icon': Icons.bathtub_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'label': 'More',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF64748B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    for (int i = 0; i < _categories.length; i++) {
      final start = (i * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.4).clamp(0.0, 1.0);
      _itemAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(start, end, curve: Curves.easeOutBack),
          ),
        ),
      );
    }

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = widget.isTablet ? 4 : 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 4,
          childAspectRatio: 0.85,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          return AnimatedBuilder(
            animation: _itemAnimations[i],
            builder: (context, child) {
              return Transform.scale(
                scale: _itemAnimations[i].value,
                child: Opacity(
                  opacity: _itemAnimations[i].value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: _CategoryCell(
              label: cat['label'] as String,
              icon: cat['icon'] as IconData,
              accentColor: cat['color'] as Color,
              isSelected: _selectedIndex == i,
              onTap: () => setState(() => _selectedIndex = i),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCell extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCell({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryCell> createState() => _CategoryCellState();
}

class _CategoryCellState extends State<_CategoryCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.92,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.accentColor
                    : widget.accentColor.withAlpha(26),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.icon,
                size: 26,
                color: widget.isSelected ? Colors.white : widget.accentColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: widget.isSelected
                    ? AppTheme.secondary
                    : const Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
