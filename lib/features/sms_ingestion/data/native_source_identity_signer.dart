import 'package:money_sync/core/crypto/keyed_hmac.dart';
import 'package:money_sync/core/security/native_security_channel.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';

/// [SourceIdentitySigner] backed by the Android Keystore HMAC key via the
/// native security channel. The platform owns exactly one source-identity
/// key, so there is no key-handle indirection here; the canonical byte
/// encoding is rebuilt natively from the structured fields.
final class NativeSourceIdentitySigner {
  const NativeSourceIdentitySigner({required this.channel});

  final NativeSecurityChannel channel;

  Future<HmacDigest> digest({
    required int canonicalizationVersion,
    required String sender,
    required String body,
    required int receivedAtEpochMs,
  }) async {
    final hex = await channel.deriveSourceIdentityDigest(
      request: SourceIdentityCanonicalizationRequest(
        senderAddress: sender,
        body: body,
        occurredAtEpochMillis: receivedAtEpochMs,
      ),
      canonicalizationVersion: canonicalizationVersion,
    );
    return HmacDigest(hex);
  }
}
