import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/app/router.dart';
import 'package:money_sync/app/share_gateway_setup.dart';
import 'package:money_sync/app/theme/app_theme.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/providers.dart';

class MoneySyncApp extends StatelessWidget {
  const MoneySyncApp({super.key, this.config});

  final AppConfig? config;

  @override
  Widget build(BuildContext context) {
    final config = this.config;
    if (config == null) return const _ConfiguredMoneySyncApp();

    return ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const _ConfiguredMoneySyncApp(),
    );
  }
}

class _ConfiguredMoneySyncApp extends ConsumerWidget {
  const _ConfiguredMoneySyncApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ShareGatewaySetup(
      child: MaterialApp.router(
        title: 'Money Sync',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
