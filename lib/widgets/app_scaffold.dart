import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './app_navigation.dart';

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool isPartner;

  const AppScaffold({
    required this.navigationShell,
    this.isPartner = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppNavigation(
        navigationShell: navigationShell,
        isPartner: isPartner,
      ),
    );
  }
}
