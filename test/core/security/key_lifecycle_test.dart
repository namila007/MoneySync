import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/security/database_key_provider.dart';

void main() {
  group('DatabaseKeyHandle lifecycle', () {
    test('zeroizes bytes even when action throws', () {
      final source = Uint8List.fromList([1, 2, 3, 4, 5]);
      final handle = DatabaseKeyHandle(source);

      expect(
        () => handle.useAndDispose((bytes) {
          throw StateError('simulated failure');
        }),
        throwsStateError,
      );

      expect(source, everyElement(0));
    });

    test('returns action result when successful', () {
      final handle = DatabaseKeyHandle(Uint8List.fromList([10, 20, 30]));

      final result = handle.useAndDispose((bytes) => bytes.length);

      expect(result, 3);
    });

    test('second use throws StateError with clear message', () {
      final handle = DatabaseKeyHandle(Uint8List.fromList([1, 2, 3]));

      handle.useAndDispose((bytes) => bytes);

      expect(
        () => handle.useAndDispose((bytes) => bytes),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('already been consumed'),
          ),
        ),
      );
    });

    test('zeroization happens in finally block', () {
      final source = Uint8List.fromList([99, 88, 77]);
      final handle = DatabaseKeyHandle(source);

      try {
        handle.useAndDispose((bytes) {
          expect(source, isNot(everyElement(0)));
          throw Exception('test');
        });
      } catch (_) {
        // Expected
      }

      expect(source, everyElement(0));
    });

    test('action receives non-null bytes', () {
      final handle = DatabaseKeyHandle(Uint8List.fromList([1, 2, 3]));

      handle.useAndDispose((bytes) {
        expect(bytes, isNotNull);
        expect(bytes.length, 3);
      });
    });

    test('large key buffers are zeroized completely', () {
      final source = Uint8List.fromList(List.generate(256, (i) => i % 256));
      final handle = DatabaseKeyHandle(source);

      handle.useAndDispose((bytes) => bytes);

      expect(source, everyElement(0));
      expect(source.length, 256);
    });

    test('action can copy bytes before zeroization', () {
      final handle = DatabaseKeyHandle(Uint8List.fromList([1, 2, 3]));

      final copied = handle.useAndDispose((bytes) => Uint8List.fromList(bytes));

      expect(copied, [1, 2, 3]);
    });

    test('original bytes are not accessible after useAndDispose', () {
      final source = Uint8List.fromList([1, 2, 3]);
      final handle = DatabaseKeyHandle(source);

      handle.useAndDispose((bytes) => bytes);

      expect(source, everyElement(0));
      expect(source, isNot([1, 2, 3]));
    });
  });

  group('DatabaseKeyAccess sealed hierarchy', () {
    test('DatabaseKeyAvailable exposes key', () {
      final handle = DatabaseKeyHandle(Uint8List.fromList([1, 2, 3]));
      final access = DatabaseKeyAvailable(handle);

      expect(access.isAvailable, isTrue);
      expect(access.requireKey(), same(handle));
    });

    test('DatabaseKeyUnavailable throws on requireKey', () {
      const access = DatabaseKeyUnavailable(
        DatabaseKeyUnavailableReason.locked,
      );

      expect(access.isAvailable, isFalse);
      expect(
        () => access.requireKey(),
        throwsA(isA<DatabaseKeyUnavailableException>()),
      );
    });

    test('all unavailable reasons are represented', () {
      for (final reason in DatabaseKeyUnavailableReason.values) {
        final access = DatabaseKeyUnavailable(reason);

        expect(access.isAvailable, isFalse);
        expect(
          () => access.requireKey(),
          throwsA(
            isA<DatabaseKeyUnavailableException>().having(
              (e) => e.reason,
              'reason',
              reason,
            ),
          ),
        );
      }
    });

    test('DatabaseKeyUnavailableException carries reason', () {
      const exception = DatabaseKeyUnavailableException(
        DatabaseKeyUnavailableReason.invalidated,
      );

      expect(exception.reason, DatabaseKeyUnavailableReason.invalidated);
    });
  });

  group('DatabaseKeyProvider interface', () {
    test('provider returns typed access result', () async {
      final provider = _FakeKeyProvider(
        DatabaseKeyAvailable(DatabaseKeyHandle(Uint8List.fromList([1, 2, 3]))),
      );

      final access = await provider.acquire();

      expect(access, isA<DatabaseKeyAccess>());
      expect(access.isAvailable, isTrue);
    });

    test('provider can return unavailable result', () async {
      const provider = _FakeKeyProvider(
        DatabaseKeyUnavailable(DatabaseKeyUnavailableReason.missing),
      );

      final access = await provider.acquire();

      expect(access, isA<DatabaseKeyAccess>());
      expect(access.isAvailable, isFalse);
    });
  });
}

class _FakeKeyProvider implements DatabaseKeyProvider {
  const _FakeKeyProvider(this._result);

  final DatabaseKeyAccess _result;

  @override
  Future<DatabaseKeyAccess> acquire() async => _result;
}
