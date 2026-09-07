import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

const _channelName = 'me.namila.money_sync/security';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot protection startup', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(_channelName), (
            MethodCall call,
          ) async {
            if (call.method == 'setSecureWindowProtection') {
              return null;
            }
            if (call.method == 'getSensitiveDatabasePath') {
              return '/tmp/test';
            }
            throw MissingPluginException();
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(_channelName), null);
    });

    test(
      'NativeSecurityChannel.setSecureWindowProtection sends enabled flag',
      () async {
        final calls = <Map<String, dynamic>?>[];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel(_channelName), (
              MethodCall call,
            ) async {
              if (call.method == 'setSecureWindowProtection') {
                calls.add(Map<String, dynamic>.from(call.arguments as Map));
                return null;
              }
              if (call.method == 'getSensitiveDatabasePath') {
                return '/tmp/test';
              }
              throw MissingPluginException();
            });

        const channel = NativeSecurityChannel();

        await channel.setSecureWindowProtection(enabled: false);
        expect(calls, hasLength(1));
        expect(calls.first!['enabled'], isFalse);

        await channel.setSecureWindowProtection(enabled: true);
        expect(calls, hasLength(2));
        expect(calls.last!['enabled'], isTrue);
      },
    );

    test('setSecureWindowProtection wraps native exceptions', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(_channelName), (
            MethodCall call,
          ) async {
            if (call.method == 'setSecureWindowProtection') {
              throw PlatformException(
                code: 'TEST_ERROR',
                message: 'test failure',
              );
            }
            throw MissingPluginException();
          });

      const channel = NativeSecurityChannel();
      expect(
        () => channel.setSecureWindowProtection(enabled: false),
        throwsA(isA<NativeChannelKeyException>()),
      );
    });
  });

  group('Logging on native-channel failure', () {
    test('Logger("security").error records the exception', () {
      final log = Logger('security');
      final records = <LogRecord>[];
      final sub = log.onRecord.listen(records.add);

      final error = Exception('channel unavailable');
      final stack = StackTrace.current;
      log.error('setSecureWindowProtection failed', error, stack);

      expect(records, hasLength(1));
      expect(records.first.level, Level.SEVERE);
      expect(records.first.message, 'setSecureWindowProtection failed');
      expect(records.first.error, error);
      expect(records.first.stackTrace, stack);

      sub.cancel();
    });
  });
}
