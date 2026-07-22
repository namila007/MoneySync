import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/crypto/keyed_hmac.dart';
import 'package:money_sync/core/security/database_key_provider.dart';
import 'package:money_sync/core/security/hmac_key_provider.dart';

void main() {
  test(
    'database-key access fails closed when no keystore key is available',
    () {
      const access = DatabaseKeyUnavailable(DatabaseKeyUnavailableReason.lost);

      expect(access.isAvailable, isFalse);
      expect(
        () => access.requireKey(),
        throwsA(
          isA<DatabaseKeyUnavailableException>().having(
            (exception) => exception.reason,
            'reason',
            DatabaseKeyUnavailableReason.lost,
          ),
        ),
      );
    },
  );

  test('HMAC key access fails closed without a plaintext fallback', () {
    const access = HmacKeyUnavailable(HmacKeyUnavailableReason.invalidated);

    expect(access.isAvailable, isFalse);
    expect(
      () => access.requireKey(),
      throwsA(
        isA<HmacKeyUnavailableException>().having(
          (exception) => exception.reason,
          'reason',
          HmacKeyUnavailableReason.invalidated,
        ),
      ),
    );
  });

  test('available key access exposes only opaque handles', () {
    final databaseHandle = DatabaseKeyHandle('database-key_01');
    final hmacHandle = HmacKeyHandle('hmac-key_01');
    final databaseAccess = DatabaseKeyAvailable(databaseHandle);
    final hmacAccess = HmacKeyAvailable(hmacHandle);

    expect(databaseAccess.isAvailable, isTrue);
    expect(databaseAccess.requireKey(), same(databaseHandle));
    expect(hmacAccess.isAvailable, isTrue);
    expect(hmacAccess.requireKey(), same(hmacHandle));
  });

  test(
    'key handles reject text that cannot be safely logged as an identifier',
    () {
      for (final invalidId in ['', 'contains space', 'emoji_🙂', 'x' * 65]) {
        expect(() => DatabaseKeyHandle(invalidId), throwsArgumentError);
        expect(() => HmacKeyHandle(invalidId), throwsArgumentError);
      }
    },
  );

  test(
    'HMAC contracts accept opaque key handles and fixed-size digests only',
    () {
      final handle = HmacKeyHandle('source-key-v1');
      final digest = HmacDigest(
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      expect(handle.id, 'source-key-v1');
      expect(digest.hex, hasLength(64));
      expect(() => HmacDigest('not-a-digest'), throwsArgumentError);
    },
  );
}
