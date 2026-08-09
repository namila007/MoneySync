import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/startup_state.dart';
import 'package:money_sync/core/security/foreground_lock.dart';
import 'package:money_sync/features/activity_log/presentation/activity_page.dart';
import 'package:money_sync/features/dashboard/presentation/home_page.dart';
import 'package:money_sync/features/data_control/presentation/data_control_page.dart';
import 'package:money_sync/features/lock/presentation/lock_page.dart';
import 'package:money_sync/features/mappings/presentation/mappings_page.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';
import 'package:money_sync/features/onboarding/presentation/onboarding_controller.dart';
import 'package:money_sync/features/onboarding/presentation/onboarding_page.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_page.dart';
import 'package:money_sync/features/settings/presentation/configuration_hub_page.dart';
import 'package:money_sync/features/settings/presentation/security_privacy_page.dart';
import 'package:money_sync/features/settings/presentation/settings_page.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_access_page.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_connection_page.dart';

final _onboardingCompletionNotifier = ValueNotifier<bool>(false);
final _lockStateNotifier = ValueNotifier<ForegroundLockState>(
  ForegroundLockState.locked,
);
final _lockRequiredNotifier = ValueNotifier<bool>(false);
final _intendedRouteNotifier = ValueNotifier<String?>(null);

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoute.onboarding.path,
    refreshListenable: Listenable.merge([
      _onboardingCompletionNotifier,
      _lockStateNotifier,
      _lockRequiredNotifier,
    ]),
    routes: [
      GoRoute(
        path: AppRoute.onboarding.path,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoute.lock.path,
        builder: (context, state) => const LockPage(),
      ),
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
        ],
      ),
      GoRoute(
        path: AppRoute.settings.path,
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'wallet',
            builder: (context, state) => const WalletConnectionPage(),
          ),
          GoRoute(
            path: 'security',
            builder: (context, state) => const SecurityPrivacyPage(),
          ),
          GoRoute(
            path: 'data',
            builder: (context, state) => const DataControlPage(),
          ),
          GoRoute(
            path: 'configuration',
            builder: (context, state) => const ConfigurationHubPage(),
            routes: [
              GoRoute(
                path: 'message-reading',
                builder: (context, state) => const SmsAccessPage(),
              ),
              GoRoute(
                path: 'history-import',
                builder: (context, state) => const _HistoryImportStub(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.onboardingReview.path,
        builder: (context, state) => const OnboardingReviewWrapper(),
      ),
    ],
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final onboarding = container.read(onboardingStateProvider);
      final startup = container.read(startupStateProvider);
      final lock = container.read(foregroundLockControllerProvider);
      return _routeGuard(
        state.matchedLocation,
        onboarding,
        startup,
        lock,
        _lockRequiredNotifier.value,
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);

  ref.listen(onboardingStateProvider, (previous, next) {
    if ((previous?.isComplete ?? false) != next.isComplete) {
      _onboardingCompletionNotifier.value = next.isComplete;
    }
  });

  ref.listen(foregroundLockControllerProvider, (_, next) {
    _lockStateNotifier.value = next;
  });

  ref.listen(configurationRepositoryProvider, (_, next) {
    next.whenData((repo) async {
      final config = await repo.load();
      _lockRequiredNotifier.value = config.appLock.enabled;
      _lockStateNotifier.value = _lockStateNotifier.value;
    });
  });

  return router;
});

String? _routeGuard(
  String matchedLocation,
  OnboardingState onboarding,
  StartupState startup,
  ForegroundLockState lock,
  bool lockRequired,
) {
  final isOnboardingRoute = matchedLocation == AppRoute.onboarding.path;
  final isLockRoute = matchedLocation == AppRoute.lock.path;

  if (startup.status == StartupStatus.ready || onboarding.isComplete) {
    if (isOnboardingRoute) return AppRoute.home.path;
  } else if (!isOnboardingRoute) {
    return AppRoute.onboarding.path;
  }

  if (lockRequired && lock == ForegroundLockState.locked && !isLockRoute) {
    _intendedRouteNotifier.value = matchedLocation;
    return AppRoute.lock.path;
  }

  if (lockRequired && lock == ForegroundLockState.unlocked && isLockRoute) {
    return _intendedRouteNotifier.value ?? AppRoute.home.path;
  }

  return null;
}

enum AppRoute {
  onboarding('/onboarding'),
  onboardingReview('/settings/onboarding'),
  lock('/lock'),
  home('/'),
  inbox('/inbox'),
  mappings('/mappings'),
  activity('/activity'),
  settings(SettingsAppBarAction.routePath),
  walletConnection('/settings/wallet'),
  securityPrivacy('/settings/security'),
  dataControl('/settings/data');

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
    final index = _primaryRoutes.indexWhere(
      (route) => path == route.path || path.startsWith('${route.path}/'),
    );
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
];

final class _PrimaryRoute {
  const _PrimaryRoute(this.route, this.label, this.icon, this.selectedIcon);

  final AppRoute route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  String get path => route.path;
}

class _HistoryImportStub extends StatelessWidget {
  const _HistoryImportStub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History import')),
      body: const Center(child: Text('History import settings \u2014 M4.8')),
    );
  }
}
