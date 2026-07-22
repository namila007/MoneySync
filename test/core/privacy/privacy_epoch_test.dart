import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/privacy/privacy_epoch.dart';

void main() {
  test('privacy epoch advances monotonically and captures stale work', () {
    final initial = PrivacyEpoch(4);
    final current = initial.advance();

    expect(current.value, 5);
    expect(
      PrivacyEpochPolicy.isCurrent(captured: initial, current: current),
      isFalse,
    );
    expect(
      PrivacyEpochPolicy.isCurrent(captured: current, current: current),
      isTrue,
    );
  });

  test('privacy epoch rejects negative values', () {
    expect(() => PrivacyEpoch(-1), throwsArgumentError);
  });
}
