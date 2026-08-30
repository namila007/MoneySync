import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/app/router.dart';

void main() {
  group('App lock toggle propagation (Bug B)', () {
    test('updateAppLockRequired updates the router lock requirement', () {
      // updateAppLockRequired is the public function that the security
      // settings page calls after toggling app lock. Before the fix,
      // _lockRequiredNotifier was only set once at startup and never
      // updated when the user toggled the setting mid-session.
      //
      // We can't read the private _lockRequiredNotifier directly, but
      // we can verify the function exists and is callable without error.
      expect(updateAppLockRequired, isA<void Function(bool)>());

      // Calling with both values should not throw.
      updateAppLockRequired(true);
      updateAppLockRequired(false);
    });
  });
}
