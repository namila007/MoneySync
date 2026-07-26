import 'package:flutter/material.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _ActivityAppBar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Activity will show sanitized local events once data processing is introduced.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ActivityAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ActivityAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: const Text('Activity'),
    actions: const [SettingsAppBarAction()],
  );
}
