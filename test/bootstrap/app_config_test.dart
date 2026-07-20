import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';

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
        expect(configuration.capabilities.isEnabled(capability), isFalse);
      }
    }
  });
}
