import '../crypto/keyed_hmac.dart';

enum HmacKeyUnavailableReason { locked, missing, invalidated, lost }

sealed class HmacKeyAccess {
  const HmacKeyAccess();

  bool get isAvailable;

  HmacKeyHandle requireKey();
}

final class HmacKeyAvailable extends HmacKeyAccess {
  const HmacKeyAvailable(this.key);

  final HmacKeyHandle key;

  @override
  bool get isAvailable => true;

  @override
  HmacKeyHandle requireKey() => key;
}

final class HmacKeyUnavailable extends HmacKeyAccess {
  const HmacKeyUnavailable(this.reason);

  final HmacKeyUnavailableReason reason;

  @override
  bool get isAvailable => false;

  @override
  HmacKeyHandle requireKey() => throw HmacKeyUnavailableException(reason);
}

final class HmacKeyUnavailableException implements Exception {
  const HmacKeyUnavailableException(this.reason);

  final HmacKeyUnavailableReason reason;
}

/// Platform adapters expose only a typed result; there is no plaintext fallback.
abstract interface class HmacKeyProvider {
  Future<HmacKeyAccess> acquire();
}
