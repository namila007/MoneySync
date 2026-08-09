import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/production_policy.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';

void main() {
  test('M0 flavor configurations are named and fail closed', () {
    const configurations = <AppConfig>[
      AppConfig.privateFull(),
      AppConfig.playManual(),
    ];

    expect(
      configurations.map((configuration) => configuration.displayName),
      <String>['Private full', 'Play manual'],
    );

    for (final configuration in configurations) {
      for (final capability in AppCapability.values) {
        final enabled = configuration.capabilities.isEnabled(capability);
        if (configuration.flavor == AppFlavor.privateFull &&
            capability == AppCapability.smsPermission) {
          expect(enabled, isTrue);
        } else {
          expect(enabled, isFalse);
        }
      }
    }
  });

  test('production flavors pin safe composition policy', () {
    const configurations = <AppConfig>[
      AppConfig.privateFull(),
      AppConfig.playManual(),
    ];

    for (final configuration in configurations) {
      expect(configuration.walletOrigin.value, 'https://rest.budgetbakers.com');
      expect(configuration.walletOrigin.isHttps, isTrue);
      expect(configuration.logPolicy.permitsSensitiveValues, isFalse);
      expect(configuration.logPolicy.permitsRequestHeaders, isFalse);
      expect(configuration.logPolicy.permitsRequestBodies, isFalse);
      expect(
        configuration.expectedNativeSurface.expects(
          NativeSurfaceCapability.smsPermissions,
        ),
        isFalse,
      );
      expect(
        configuration.expectedNativeSurface.expects(
          NativeSurfaceCapability.smsReceiver,
        ),
        isFalse,
      );
      expect(
        configuration.expectedNativeSurface.expects(
          NativeSurfaceCapability.walletMutationTransport,
        ),
        isFalse,
      );
      expect(
        configuration.compileTimeFlavorConstraints.allows(
          CompileTimeFlavorConstraint.testWalletTransport,
        ),
        isFalse,
      );
      expect(
        configuration.walletMutationPort,
        isA<ProductionDisabledWalletMutationPort>(),
      );
    }
  });

  test('ordinary preferences cannot enable evidence-gated capabilities', () {
    final preference = UserCapabilityPreference(AppCapability.values);
    const configurations = <AppConfig>[
      AppConfig.privateFull(),
      AppConfig.playManual(),
    ];

    for (final configuration in configurations) {
      final resolved = configuration.capabilitiesFor(preference);

      for (final capability in AppCapability.values) {
        expect(resolved.isEnabled(capability), isFalse);
      }
    }
  });
}
