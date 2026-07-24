import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class HomeAppBarWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final blurAmount = (scrollOffset / 60).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
      decoration: BoxDecoration(
        color: Color.lerp(
          Colors.transparent,
          const Color(0xFF080E1A).withAlpha(220),
          blurAmount,
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withAlpha((blurAmount * 18).toInt()),
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
                color: const Color(0xFF00C896).withAlpha(160),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C896).withAlpha(50),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: avatarUrl,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                semanticLabel: 'Profile photo of $userName',
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
                  greeting,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(120),
                  ),
                ),
                Text(
                  userName,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withAlpha(18), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 12,
                  color: const Color(0xFF00C896),
                ),
                const SizedBox(width: 4),
                Text(
                  'Mumbai',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: Colors.white.withAlpha(120),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Notification button
          Stack(
            clipBehavior: Clip.none,
            children: [
              _IconBtn(
                icon: Icons.notifications_none_rounded,
                onTap: onNotificationTap,
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF080E1A),
                      width: 1.5,
                    ),
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
          color: Colors.white.withAlpha(10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(18), width: 1),
        ),
        child: Icon(icon, size: 19, color: Colors.white.withAlpha(200)),
      ),
    );
  }
}
