import 'package:flutter/material.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [const SettingsAppBarAction()],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Your local review workspace is ready. Financial integrations are disabled until their safety gates pass.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
