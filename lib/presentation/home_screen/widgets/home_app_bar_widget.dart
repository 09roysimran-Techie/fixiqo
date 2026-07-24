import '../../../core/app_export.dart';

class HomeAppBarWidget extends StatelessWidget {
  final String greeting;
  final String userName;
  final String avatarUrl;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  const HomeAppBarWidget({
    required this.greeting,
    required this.userName,
    required this.avatarUrl,
    required this.onSearchTap,
    required this.onNotificationTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.outlineLight.withAlpha(128),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary, width: 2),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: avatarUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                semanticLabel: 'Profile photo of $userName',
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Greeting + name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Search button
          _IconActionButton(icon: Icons.search_rounded, onTap: onSearchTap),
          const SizedBox(width: 8),

          // Notification button with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              _IconActionButton(
                icon: Icons.notifications_none_rounded,
                onTap: onNotificationTap,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppTheme.error,
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

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      splashColor: AppTheme.primary.withAlpha(31),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppTheme.secondary),
      ),
    );
  }
}
