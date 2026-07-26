import 'package:flutter/material.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';

class MappingsPage extends StatelessWidget {
  const MappingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _MappingsAppBar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Mappings will be available after the local encrypted data foundation is complete.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _MappingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MappingsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: const Text('Mappings'),
    actions: const [SettingsAppBarAction()],
  );
}
