import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/login_hero_widget.dart';
import './widgets/social_auth_widget.dart';

class SignUpLoginScreen extends StatelessWidget {
  const SignUpLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: isTablet ? _buildTabletLayout(context) : _buildPhoneLayout(context),
    );
  }

  Widget _buildPhoneLayout(BuildContext context) {
    return Stack(
      children: [
        const LoginHeroWidget(),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SocialAuthWidget(
            onSignedIn: () => context.go(AppRoutes.roleSelectionScreen),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Stack(
      children: [
        const LoginHeroWidget(),
        Center(
          child: Container(
            width: 480,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SocialAuthWidget(
                  onSignedIn: () => context.go(AppRoutes.roleSelectionScreen),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
