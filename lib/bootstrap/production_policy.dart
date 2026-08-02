import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';

/// Pinned, HTTPS-only Wallet origin. Paths are selected by audited transports.
final class WalletHttpsOrigin {
  const WalletHttpsOrigin._();

  static const budgetBakers = WalletHttpsOrigin._();

  String get value => 'https://rest.budgetbakers.com';

  bool get isHttps => true;
}

/// Production logging permits metadata only; values, headers, and bodies stay out.
final class SafeLogPolicy {
  const SafeLogPolicy.production()
    : permitsSensitiveValues = false,
      permitsRequestHeaders = false,
      permitsRequestBodies = false,
      permitsDebugLog = false;

  const SafeLogPolicy.debug()
    : permitsSensitiveValues = false,
      permitsRequestHeaders = false,
      permitsRequestBodies = false,
      permitsDebugLog = true;

  final bool permitsSensitiveValues;
  final bool permitsRequestHeaders;
  final bool permitsRequestBodies;
  final bool permitsDebugLog;
}

/// Native integrations that a flavor is allowed to expect at startup.
enum NativeSurfaceCapability {
  smsPermissions,
  smsReceiver,
  walletMutationTransport,
}

/// The M0 native surface is deliberately empty until its evidence gates pass.
final class ExpectedNativeSurface {
  const ExpectedNativeSurface.m0();

  bool expects(NativeSurfaceCapability capability) => false;
}

/// Features a production flavor must never source from a test composition.
enum CompileTimeFlavorConstraint { testWalletTransport }

/// Fixed build constraints; ordinary runtime settings cannot change them.
final class CompileTimeFlavorConstraints {
  const CompileTimeFlavorConstraints.m0();

  bool allows(CompileTimeFlavorConstraint constraint) => false;

  /// Production flavors have no fake or live mutation transport selection.
  WalletMutationPort resolveWalletMutationPort() =>
      const ProductionDisabledWalletMutationPort();
}

/// A user-level request for capabilities. It is a request, never an entitlement.
final class UserCapabilityPreference {
  UserCapabilityPreference(Iterable<AppCapability> requestedCapabilities)
    : requestedCapabilities = Set.unmodifiable(requestedCapabilities);

  final Set<AppCapability> requestedCapabilities;
}

/// Immutable production composition policy for the M0 capability baseline.
final class ProductionPolicy {
  const ProductionPolicy.m0();

  static const _walletOrigin = WalletHttpsOrigin.budgetBakers;
  static const _logPolicy = SafeLogPolicy.production();
  static const _expectedNativeSurface = ExpectedNativeSurface.m0();
  static const _compileTimeFlavorConstraints =
      CompileTimeFlavorConstraints.m0();

  WalletHttpsOrigin get walletOrigin => _walletOrigin;

  SafeLogPolicy get logPolicy => _logPolicy;

  ExpectedNativeSurface get expectedNativeSurface => _expectedNativeSurface;

  CompileTimeFlavorConstraints get compileTimeFlavorConstraints =>
      _compileTimeFlavorConstraints;

  /// Evidence-gated capabilities cannot be granted by an ordinary preference.
  AppCapabilities capabilitiesFor(UserCapabilityPreference _) =>
      const AppCapabilities.m0();
}
