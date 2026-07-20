import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            key: const ValueKey('open-settings'),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoute.settings.path),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
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
