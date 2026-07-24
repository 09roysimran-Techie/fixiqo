import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      'color': Color(0xFF00C896),
      'bg': Color(0xFF00C896),
    },
    {
      'label': 'Plumbing',
      'icon': Icons.plumbing_rounded,
      'color': Color(0xFF60A5FA),
      'bg': Color(0xFF60A5FA),
    },
    {
      'label': 'Electrical',
      'icon': Icons.electrical_services_rounded,
      'color': Color(0xFFFF6B35),
      'bg': Color(0xFFFF6B35),
    },
    {
      'label': 'AC Repair',
      'icon': Icons.ac_unit_rounded,
      'color': Color(0xFF818CF8),
      'bg': Color(0xFF818CF8),
    },
    {
      'label': 'Painting',
      'icon': Icons.format_paint_rounded,
      'color': Color(0xFFF472B6),
      'bg': Color(0xFFF472B6),
    },
    {
      'label': 'Repair',
      'icon': Icons.construction_rounded,
      'color': Color(0xFFFBBF24),
      'bg': Color(0xFFFBBF24),
    },
    {
      'label': 'Bathroom',
      'icon': Icons.bathtub_rounded,
      'color': Color(0xFF34D399),
      'bg': Color(0xFF34D399),
    },
    {
      'label': 'More',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF94A3B8),
      'bg': Color(0xFF94A3B8),
    },
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    for (int i = 0; i < _categories.length; i++) {
      final start = (i * 0.07).clamp(0.0, 0.65);
      final end = (start + 0.45).clamp(0.0, 1.0);
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
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
      lowerBound: 0.93,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.accentColor.withAlpha(30)
                : Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? widget.accentColor.withAlpha(120)
                  : Colors.white.withAlpha(16),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.accentColor.withAlpha(50)
                      : widget.accentColor.withAlpha(22),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(widget.icon, size: 22, color: widget.accentColor),
              ),
              const SizedBox(height: 7),
              Text(
                widget.label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? Colors.white
                      : Colors.white.withAlpha(150),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
