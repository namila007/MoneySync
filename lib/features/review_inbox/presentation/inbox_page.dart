import 'package:flutter/material.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderFeaturePage(
      title: 'Inbox',
      message: 'No transaction candidates are available yet.',
    );
  }
}

class _PlaceholderFeaturePage extends StatelessWidget {
  const _PlaceholderFeaturePage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [SettingsAppBarAction()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
