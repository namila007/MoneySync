import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';

void main() {
  test('M0 capabilities fail closed with an explanation', () {
    const capabilities = AppCapabilities.m0();

    for (final capability in AppCapability.values) {
      expect(capabilities.isEnabled(capability), isFalse);
      expect(capabilities.explanationFor(capability), isNotEmpty);
    }
  });
}
