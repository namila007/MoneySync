import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/logging/log_config.dart';
import 'package:money_sync/bootstrap/production_policy.dart';

void main() {
  group('CompileTimeDebugGuard', () {
    test('production SafeLogPolicy does not permit debug log', () {
      const policy = SafeLogPolicy.production();
      expect(policy.permitsDebugLog, isFalse);
      expect(policy.permitsSensitiveValues, isFalse);
      expect(policy.permitsRequestHeaders, isFalse);
      expect(policy.permitsRequestBodies, isFalse);
    });

    test('debug SafeLogPolicy permits debug log but not sensitive data', () {
      const policy = SafeLogPolicy.debug();
      expect(policy.permitsDebugLog, isTrue);
      expect(policy.permitsSensitiveValues, isFalse);
      expect(policy.permitsRequestHeaders, isFalse);
      expect(policy.permitsRequestBodies, isFalse);
    });

    test('privateFull LogConfig has debug log disabled', () {
      const config = LogConfig(
        flavor: 'privateFull',
        enableDebugLog: false,
        safeLogPolicy: SafeLogPolicy.production(),
      );
      expect(config.enableDebugLog, isFalse);
      expect(config.safeLogPolicy.permitsDebugLog, isFalse);
    });

    test('playManual LogConfig with flag has debug log enabled', () {
      const config = LogConfig(
        flavor: 'playManual',
        enableDebugLog: true,
        safeLogPolicy: SafeLogPolicy.debug(),
      );
      expect(config.enableDebugLog, isTrue);
      expect(config.safeLogPolicy.permitsDebugLog, isTrue);
    });
  });
}
