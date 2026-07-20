import 'package:money_sync/core/capabilities/app_capabilities.dart';

enum AppFlavor { privateFull, playManual }

/// Immutable composition input for an application process.
///
/// M0 deliberately provides only fail-closed capability configurations. Future
/// milestones must add an audited composition path rather than mutate this
/// object from a user preference.
final class AppConfig {
  const AppConfig._({required this.flavor, required this.capabilities});

  const AppConfig.privateFull()
    : this._(
        flavor: AppFlavor.privateFull,
        capabilities: const AppCapabilities.m0(),
      );

  const AppConfig.playManual()
    : this._(
        flavor: AppFlavor.playManual,
        capabilities: const AppCapabilities.m0(),
      );

  final AppFlavor flavor;
  final AppCapabilities capabilities;

  String get displayName => switch (flavor) {
    AppFlavor.privateFull => 'Private full',
    AppFlavor.playManual => 'Play manual',
  };
}
