import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/bootstrap/production_policy.dart';

enum AppFlavor { privateFull, playManual }

/// Immutable composition input for an application process.
///
/// M0 deliberately provides only fail-closed capability configurations. Future
/// milestones must add an audited composition path rather than mutate this
/// object from a user preference.
final class AppConfig {
  const AppConfig._({
    required this.flavor,
    required this.capabilities,
    required this.productionPolicy,
  });

  const AppConfig.privateFull()
    : this._(
        flavor: AppFlavor.privateFull,
        capabilities: const AppCapabilities.m4PrivateFull(),
        productionPolicy: const ProductionPolicy.m0(),
      );

  const AppConfig.playManual()
    : this._(
        flavor: AppFlavor.playManual,
        capabilities: const AppCapabilities.m0(),
        productionPolicy: const ProductionPolicy.m0(),
      );

  const AppConfig.withFlavor(AppFlavor flavor)
    : this._(
        flavor: flavor,
        capabilities: flavor == AppFlavor.privateFull
            ? const AppCapabilities.m4PrivateFull()
            : const AppCapabilities.m0(),
        productionPolicy: const ProductionPolicy.m0(),
      );

  final AppFlavor flavor;
  final AppCapabilities capabilities;

  /// Fixed policy compiled into this entry point, not a mutable user setting.
  final ProductionPolicy productionPolicy;

  WalletHttpsOrigin get walletOrigin => productionPolicy.walletOrigin;

  SafeLogPolicy get logPolicy => productionPolicy.logPolicy;

  ExpectedNativeSurface get expectedNativeSurface =>
      productionPolicy.expectedNativeSurface;

  CompileTimeFlavorConstraints get compileTimeFlavorConstraints =>
      productionPolicy.compileTimeFlavorConstraints;

  /// Config can resolve only the permanent, no-write production mutation port.

  /// Preferences are advisory only; capability activation needs audited evidence.
  AppCapabilities capabilitiesFor(UserCapabilityPreference preference) =>
      productionPolicy.capabilitiesFor(preference);

  String get displayName => switch (flavor) {
    AppFlavor.privateFull => 'Private full',
    AppFlavor.playManual => 'Play manual',
  };
}
