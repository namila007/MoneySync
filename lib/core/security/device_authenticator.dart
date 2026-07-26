import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum DeviceAuthOutcome {
  authenticated,
  notEnrolled,
  notAvailable,
  cancelled,
  failed,
  lockedOut,
}

final class DeviceAuthEvidence {
  const DeviceAuthEvidence._({
    required this.authenticatedAt,
    required this.purpose,
  });

  factory DeviceAuthEvidence.authenticated({
    required DateTime authenticatedAt,
    required String purpose,
  }) {
    return DeviceAuthEvidence._(
      authenticatedAt: authenticatedAt,
      purpose: purpose,
    );
  }

  final DateTime authenticatedAt;
  final String purpose;

  bool isFreshFor({
    required String purpose,
    Duration maxAge = const Duration(seconds: 30),
  }) {
    if (this.purpose != purpose) return false;
    return DateTime.now().difference(authenticatedAt) < maxAge;
  }
}

abstract interface class FreshAuthPort {
  Future<DeviceAuthOutcome> authenticate({required String purpose});

  Future<bool> isDeviceAuthAvailable();
}

final class LocalAuthDeviceAuthenticator implements FreshAuthPort {
  LocalAuthDeviceAuthenticator({required this.auth});

  final LocalAuthentication auth;

  @override
  Future<DeviceAuthOutcome> authenticate({required String purpose}) async {
    try {
      final canAuth =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuth) return DeviceAuthOutcome.notAvailable;

      final didAuthenticate = await auth.authenticate(
        localizedReason: purpose,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate) return DeviceAuthOutcome.authenticated;
      return DeviceAuthOutcome.cancelled;
    } on PlatformException catch (e) {
      return switch (e.code) {
        'NotEnrolled' => DeviceAuthOutcome.notEnrolled,
        'NotAvailable' => DeviceAuthOutcome.notAvailable,
        'LockedOut' || 'PermanentlyLockedOut' => DeviceAuthOutcome.lockedOut,
        _ => DeviceAuthOutcome.failed,
      };
    }
  }

  @override
  Future<bool> isDeviceAuthAvailable() async {
    try {
      return await auth.canCheckBiometrics || await auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }
}
