import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../services/notification_service.dart';

class HomeAppBarWidget extends StatefulWidget {
  final String greeting;
  final String userName;
  final String avatarUrl;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final double scrollOffset;

  const HomeAppBarWidget({
    required this.greeting,
    required this.userName,
    required this.avatarUrl,
    required this.onSearchTap,
    required this.onNotificationTap,
    this.scrollOffset = 0,
    super.key,
  });

  @override
  State<HomeAppBarWidget> createState() => _HomeAppBarWidgetState();
}

class _HomeAppBarWidgetState extends State<HomeAppBarWidget> {
  final NotificationService _notificationService = NotificationService.instance;

  @override
  void initState() {
    super.initState();
    _notificationService.addListener(_onNotificationsChanged);
    _notificationService.startListening('demo-homeowner-001');
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blurAmount = (widget.scrollOffset / 60).clamp(0.0, 1.0);
    final unreadCount = _notificationService.unreadCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
      decoration: BoxDecoration(
        color: Color.lerp(
          Colors.transparent,
          Colors.white.withAlpha(230),
          blurAmount,
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.outlineLight.withAlpha((blurAmount * 200).toInt()),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withAlpha(160),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withAlpha(40),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: widget.avatarUrl,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                semanticLabel: 'Profile photo of ${widget.userName}',
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.greeting,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  widget.userName,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          // Location chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppTheme.outlineLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 12,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Mumbai',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Notification button with live unread badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              _IconBtn(
                icon: unreadCount > 0
                    ? Icons.notifications_rounded
                    : Icons.notifications_none_rounded,
                onTap: widget.onNotificationTap,
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.outlineLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 19, color: const Color(0xFF1A1A2E)),
      ),
    );
  }
}
