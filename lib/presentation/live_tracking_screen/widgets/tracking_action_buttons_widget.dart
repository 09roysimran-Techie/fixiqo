import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class TrackingActionButtonsWidget extends StatelessWidget {
  final String technicianPhone;
  final VoidCallback onCall;
  final VoidCallback onChat;

  const TrackingActionButtonsWidget({
    required this.technicianPhone,
    required this.onCall,
    required this.onChat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.call_rounded,
            label: 'Call Technician',
            backgroundColor: AppTheme.primary,
            textColor: Colors.white,
            onTap: onCall,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.chat_bubble_rounded,
            label: 'Chat',
            backgroundColor: AppTheme.surfaceLight,
            textColor: AppTheme.secondary,
            borderColor: AppTheme.outlineLight,
            onTap: onChat,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(100),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : null,
            boxShadow: widget.backgroundColor == AppTheme.primary
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(89),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: widget.textColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
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
