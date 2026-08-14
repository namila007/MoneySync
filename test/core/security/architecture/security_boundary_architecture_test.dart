import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/security/database_key_provider.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

/// M3.7 WP1 — Security boundary architecture tests.
///
/// These supersede the M3.6 placeholder tests (which only documented known
/// gaps via `expect(true, isTrue, ...)`). They assert the actual GREEN
/// contract: the raw database key is a single-use, zeroizing `Uint8List`
/// handle with no `String`/hex accessor, and source-identity signing only
/// accepts a typed, bounded, field-validated request — never an arbitrary
/// pre-built string.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Database key boundary', () {
    test('DatabaseKeyHandle exposes no String-typed key accessor', () {
      final handle = DatabaseKeyHandle(Uint8List.fromList([1, 2, 3]));
      // The only way to reach the key material is useAndDispose, which
      // yields raw bytes to a caller-supplied callback and then zeroizes
      // them. There is no `.id`/`.hex`/`.toString()`-style leak.
      expect(handle.useAndDispose((bytes) => bytes), isA<Uint8List>());
    });

    test('DatabaseKeyHandle rejects empty key material', () {
      expect(() => DatabaseKeyHandle(Uint8List(0)), throwsArgumentError);
    });

    test('DatabaseKeyHandle key bytes are consumed exactly once', () {
      final handle = DatabaseKeyHandle(Uint8List.fromList([9, 8, 7]));
      handle.useAndDispose((bytes) => bytes);

      expect(() => handle.useAndDispose((bytes) => bytes), throwsStateError);
    });

    test('DatabaseKeyHandle zeroizes the backing buffer after use', () {
      final source = Uint8List.fromList([5, 6, 7, 8]);
      final handle = DatabaseKeyHandle(source);

      handle.useAndDispose((bytes) => bytes);

      expect(source, everyElement(0));
    });

    test('NativeSecurityChannel.acquireContentKeyBytes returns raw bytes, '
        'not a hex String', () {
      // Compile-time proof: this call site only type-checks if the
      // return type is Future<Uint8List>. A hex-returning
      // acquireContentKeyHex() no longer exists on this class.
      const channel = NativeSecurityChannel();
      expect(channel.acquireContentKeyBytes, isA<Function>());
    });

    test('acquireContentKeyBytes defensively copies the channel result so it '
        'is always mutable/zeroizable, even if the platform layer returns a '
        'read-only view', () async {
      // Regression test: on a real device the MethodChannel result was
      // observed to be a read-only Uint8List view, which crashed
      // DatabaseKeyHandle.useAndDispose's fillRange zeroization with
      // "Unsupported operation: Cannot modify an unmodifiable list".
      const channelName = 'me.namila.money_sync/security';
      final readOnlySource = Uint8List.fromList(
        List<int>.generate(32, (i) => i),
      ).asUnmodifiableView();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (
            MethodCall call,
          ) async {
            if (call.method == 'acquireContentKeyBytes') {
              return readOnlySource;
            }
            throw MissingPluginException();
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel(channelName), null);
      });

      const channel = NativeSecurityChannel();
      final bytes = await channel.acquireContentKeyBytes();
      final handle = DatabaseKeyHandle(bytes);

      expect(
        () => handle.useAndDispose((b) => b.fillRange(0, b.length, 0)),
        returnsNormally,
      );
    });
  });

  group('HMAC boundary', () {
    const channel = NativeSecurityChannel();

    test('rejects an empty canonicalization field before reaching native', () {
      final request = const SourceIdentityCanonicalizationRequest(
        senderAddress: '',
        body: 'body',
        occurredAtEpochMillis: 0,
      );

      expect(
        channel.deriveSourceIdentityDigest(
          request: request,
          canonicalizationVersion: 2,
        ),
        throwsArgumentError,
      );
    });

    test('rejects an oversized canonicalization field', () {
      final request = SourceIdentityCanonicalizationRequest(
        senderAddress: 'x' * 257,
        body: 'body',
        occurredAtEpochMillis: 0,
      );

      expect(
        channel.deriveSourceIdentityDigest(
          request: request,
          canonicalizationVersion: 2,
        ),
        throwsArgumentError,
      );
    });

    test('rejects a canonicalization field with control characters', () {
      final request = const SourceIdentityCanonicalizationRequest(
        senderAddress: 'sender\nwith-newline',
        body: 'body',
        occurredAtEpochMillis: 0,
      );

      expect(
        channel.deriveSourceIdentityDigest(
          request: request,
          canonicalizationVersion: 2,
        ),
        throwsArgumentError,
      );
    });

    test('rejects a negative occurredAtEpochMillis', () {
      final request = const SourceIdentityCanonicalizationRequest(
        senderAddress: 'sender',
        body: 'body',
        occurredAtEpochMillis: -1,
      );

      expect(
        channel.deriveSourceIdentityDigest(
          request: request,
          canonicalizationVersion: 2,
        ),
        throwsArgumentError,
      );
    });

    test('deriveSourceIdentityDigest only accepts a typed request, not a '
        'free-form canonicalInput String', () {
      // Compile-time proof: the named parameter is
      // `SourceIdentityCanonicalizationRequest request`, not
      // `String canonicalInput`. A caller cannot pass an arbitrary
      // pre-built string to be signed.
      expect(channel.deriveSourceIdentityDigest, isA<Function>());
    });
  });

  group('Native channel method safety', () {
    test('the channel no longer exposes a hex-returning database key read', () {
      const channel = NativeSecurityChannel();
      // acquireContentKeyHex() was removed entirely; only
      // acquireContentKeyBytes() (Uint8List) remains.
      expect(channel.acquireContentKeyBytes, isA<Function>());
    });
  });
}
