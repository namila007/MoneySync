import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:money_sync/core/crypto/keyed_hmac.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';

/// Deterministic [SourceIdentitySigner] for tests: sha256 over the
/// length-prefixed canonical pre-image. Stable across signer instances
/// (process-restart stability) and field-boundary-safe, which is what the
/// identity tests exercise. Real key material lives in the platform Keystore.
SourceIdentitySigner fakeIdentitySigner() {
  return ({
    required int canonicalizationVersion,
    required String sender,
    required String body,
    required int receivedAtEpochMs,
  }) async {
    final preimage = StringBuffer('v$canonicalizationVersion');
    for (final field in [sender, body, receivedAtEpochMs.toString()]) {
      preimage
        ..write('|')
        ..write(field.length)
        ..write(':')
        ..write(field);
    }
    return HmacDigest(
      sha256.convert(utf8.encode(preimage.toString())).toString(),
    );
  };
}
