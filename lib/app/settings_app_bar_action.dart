import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A consistent Settings entry point for each primary screen app bar.
class SettingsAppBarAction extends StatelessWidget {
  const SettingsAppBarAction({super.key});

  static const routePath = '/settings';

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('open-settings'),
      tooltip: 'Settings',
      onPressed: () => context.push(routePath),
      icon: const Icon(Icons.settings_outlined),
    );
  }
}
