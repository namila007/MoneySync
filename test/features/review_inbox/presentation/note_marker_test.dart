import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/review_inbox/presentation/review_transaction_controller.dart';

/// M5.22 WP-O. plan/05:159 requires the note source marker to carry "96
/// truncated HMAC bits by default and never fewer than 80 bits", and warns
/// "never shorten it to a six-character example".
///
/// The old generator was the millisecond clock in base36, zero-padded to 16.
/// On device that produced `[sw:00000000MT81XFN3]` — eight literal zeros and
/// no unpredictability at all. Because plan/05:167 makes marker lookup the
/// go/no-go gate for writes, a colliding marker can reconcile the WRONG
/// record and confirm a duplicate as the original.
void main() {
  String markerOf(String note) {
    final built = ReviewTransactionController.buildNoteWithMarkerForTest(note)!;
    final start = built.indexOf('[sw:') + 4;
    return built.substring(start, built.indexOf(']', start));
  }

  test('carries at least 80 bits of entropy in its alphabet space', () {
    final marker = markerOf('');
    // 20 chars over a 32-symbol alphabet = 100 bits of space, 96 of entropy.
    expect(marker.length, 20);
    expect(marker, matches(RegExp(r'^[0-9A-HJKMNP-TV-Z]{20}$')));
  });

  test('is not the zero-padded clock the old generator produced', () {
    final marker = markerOf('');
    expect(
      marker.startsWith('00000000'),
      isFalse,
      reason: 'the old timestamp marker always began with eight zeros',
    );
  });

  test('two markers generated back to back differ', () {
    // The old generator returned an identical value for any two creates
    // inside the same millisecond.
    final markers = <String>{for (var i = 0; i < 200; i++) markerOf('')};
    expect(
      markers,
      hasLength(200),
      reason: 'markers must not collide — they are the reconciliation key',
    );
  });

  test('a user note is preserved after the marker', () {
    final built = ReviewTransactionController.buildNoteWithMarkerForTest(
      'coffee with team',
    )!;
    expect(built, contains('coffee with team'));
    expect(built, startsWith('[sw:'));
  });

  test('the whole note stays within the 255-character wire limit', () {
    final built = ReviewTransactionController.buildNoteWithMarkerForTest(
      'x' * 400,
    )!;
    expect(built.length, lessThanOrEqualTo(255));
    // The marker is never the part that gets truncated.
    expect(markerOf('x' * 400).length, 20);
  });
}
