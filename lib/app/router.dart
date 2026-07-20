import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/features/activity_log/presentation/activity_page.dart';
import 'package:money_sync/features/dashboard/presentation/home_page.dart';
import 'package:money_sync/features/mappings/presentation/mappings_page.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_page.dart';
import 'package:money_sync/features/settings/presentation/settings_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoute.inbox.path,
            builder: (context, state) => const InboxPage(),
          ),
          GoRoute(
            path: AppRoute.mappings.path,
            builder: (context, state) => const MappingsPage(),
          ),
          GoRoute(
            path: AppRoute.activity.path,
            builder: (context, state) => const ActivityPage(),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}

enum AppRoute {
  home('/'),
  inbox('/inbox'),
  mappings('/mappings'),
  activity('/activity'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}

class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Semantics(
        label: 'Primary navigation',
        child: NavigationBar(
          selectedIndex: _selectedIndex(location),
          onDestinationSelected: (index) {
            final route = _primaryRoutes[index].route;
            context.go(route.path);
          },
          destinations: [
            for (final route in _primaryRoutes)
              NavigationDestination(
                icon: Tooltip(message: route.label, child: Icon(route.icon)),
                selectedIcon: Tooltip(
                  message: route.label,
                  child: Icon(route.selectedIcon),
                ),
                label: route.label,
              ),
          ],
        ),
      ),
    );
  }

  int _selectedIndex(String path) {
    final index = _primaryRoutes.indexWhere((route) => route.path == path);
    return index < 0 ? 0 : index;
  }
}

const _primaryRoutes = <_PrimaryRoute>[
  _PrimaryRoute(AppRoute.home, 'Home', Icons.home_outlined, Icons.home),
  _PrimaryRoute(AppRoute.inbox, 'Inbox', Icons.inbox_outlined, Icons.inbox),
  _PrimaryRoute(
    AppRoute.mappings,
    'Mappings',
    Icons.account_tree_outlined,
    Icons.account_tree,
  ),
  _PrimaryRoute(
    AppRoute.activity,
    'Activity',
    Icons.receipt_long_outlined,
    Icons.receipt_long,
  ),
  _PrimaryRoute(
    AppRoute.settings,
    'Settings',
    Icons.settings_outlined,
    Icons.settings,
  ),
];

final class _PrimaryRoute {
  const _PrimaryRoute(this.route, this.label, this.icon, this.selectedIcon);

  final AppRoute route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  String get path => route.path;
}
