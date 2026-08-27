import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/onboarding/presentation/steps/notification_permission_decision_step.dart';
import 'package:money_sync/features/onboarding/presentation/steps/sms_access_decision_step.dart';
import 'package:money_sync/features/onboarding/presentation/steps/sms_access_disclosure_step.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_gateway.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_status.dart';
import 'package:money_sync/features/notification_permission/presentation/notification_permission_controller.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

/// Mirrors the host that `OnboardingPage` builds around every step:
/// `Expanded > SingleChildScrollView > step`. The scroll view hands the step an
/// unbounded height, so a step that puts a flex child directly in its own
/// Column fails to lay out and renders nothing.
///
/// See onboarding_page.dart:41-59.
Widget _inOnboardingHost(
  Widget step, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const SizedBox(height: 32),
              Expanded(child: SingleChildScrollView(child: step)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _scoped(
  Widget child, {
  SmsPermissionGateway? gateway,
  NotificationPermissionGateway? notificationGateway,
}) {
  return ProviderScope(
    overrides: [
      if (gateway != null)
        smsPermissionGatewayProvider.overrideWithValue(gateway),
      if (notificationGateway != null)
        notificationPermissionGatewayProvider.overrideWithValue(
          notificationGateway,
        ),
    ],
    child: child,
  );
}

void main() {
  group('SmsAccessDisclosureStep inside the onboarding scroll host', () {
    testWidgets('renders its heading and both decision affordances', (
      tester,
    ) async {
      await tester.pumpWidget(
        _scoped(_inOnboardingHost(const SmsAccessDisclosureStep())),
      );
      await tester.pump();

      expect(find.text('Reading your bank messages'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.textContaining('Not now'), findsOneWidget);
    });

    testWidgets('lays out without a flex-under-unbounded-height failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        _scoped(_inOnboardingHost(const SmsAccessDisclosureStep())),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('SmsAccessDecisionStep inside the onboarding scroll host', () {
    testWidgets('renders the unavailable-in-build copy for playManual', (
      tester,
    ) async {
      await tester.pumpWidget(
        _scoped(
          _inOnboardingHost(const SmsAccessDecisionStep()),
          gateway: _FixedGateway(SmsPermissionStatus.unavailableInBuild),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Paste or share to import'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the granted copy', (tester) async {
      await tester.pumpWidget(
        _scoped(
          _inOnboardingHost(const SmsAccessDecisionStep()),
          gateway: _FixedGateway(SmsPermissionStatus.granted),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Message reading is on'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'renders the off copy when the permission was never asked for',
      (tester) async {
        await tester.pumpWidget(
          _scoped(
            _inOnboardingHost(const SmsAccessDecisionStep()),
            gateway: _FixedGateway(SmsPermissionStatus.notRequested),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Message reading is off'), findsOneWidget);
        expect(find.text('Finish'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('permanentlyDenied shows Open system settings, not Try again', (
      tester,
    ) async {
      await tester.pumpWidget(
        _scoped(
          _inOnboardingHost(const SmsAccessDecisionStep()),
          gateway: _FixedGateway(SmsPermissionStatus.permanentlyDenied),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Open system settings'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
      expect(find.text('Finish'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('gateway failure still allows Finish', (tester) async {
      await tester.pumpWidget(
        _scoped(
          _inOnboardingHost(const SmsAccessDecisionStep()),
          gateway: _ThrowingGateway(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Message reading status unavailable'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the checking copy while the status is still loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        _scoped(
          _inOnboardingHost(const SmsAccessDecisionStep()),
          gateway: _NeverCompletingGateway(),
        ),
      );
      await tester.pump();

      expect(find.text('Checking message reading status'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group(
    'NotificationPermissionDecisionStep inside the onboarding scroll host',
    () {
      testWidgets('renders the granted copy', (tester) async {
        await tester.pumpWidget(
          _scoped(
            _inOnboardingHost(const NotificationPermissionDecisionStep()),
            notificationGateway: _FixedNotificationGateway(
              NotificationPermissionStatus.granted,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Notifications are on'), findsOneWidget);
        expect(find.text('Finish'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders the off copy when not requested', (tester) async {
        await tester.pumpWidget(
          _scoped(
            _inOnboardingHost(const NotificationPermissionDecisionStep()),
            notificationGateway: _FixedNotificationGateway(
              NotificationPermissionStatus.notRequested,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Notifications are off'), findsOneWidget);
        expect(find.text('Finish'), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('permanentlyDenied shows Open system settings', (
        tester,
      ) async {
        await tester.pumpWidget(
          _scoped(
            _inOnboardingHost(const NotificationPermissionDecisionStep()),
            notificationGateway: _FixedNotificationGateway(
              NotificationPermissionStatus.permanentlyDenied,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Open system settings'), findsOneWidget);
        expect(find.text('Try again'), findsNothing);
        expect(find.text('Finish'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('gateway failure still allows Finish', (tester) async {
        await tester.pumpWidget(
          _scoped(
            _inOnboardingHost(const NotificationPermissionDecisionStep()),
            notificationGateway: _ThrowingNotificationGateway(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Notification status unavailable'), findsOneWidget);
        expect(find.text('Finish'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'renders the checking copy while the status is still loading',
        (tester) async {
          await tester.pumpWidget(
            _scoped(
              _inOnboardingHost(const NotificationPermissionDecisionStep()),
              notificationGateway: _NeverCompletingNotificationGateway(),
            ),
          );
          await tester.pump();

          expect(find.text('Checking notification status'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    },
  );

  group('accessibility (M4.3 exit criteria)', () {
    testWidgets('disclosure step is fully readable at 200% text scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        _scoped(
          _inOnboardingHost(
            const SmsAccessDisclosureStep(),
            textScaler: const TextScaler.linear(2.0),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Reading your bank messages'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.textContaining('Not now'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('status glyph is excluded from semantics; the label carries '
        'meaning', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _scoped(
          _inOnboardingHost(const SmsAccessDecisionStep()),
          gateway: _FixedGateway(SmsPermissionStatus.granted),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Message reading is on'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Message reading is on')).label,
        contains('On'),
      );
      expect(find.bySemanticsLabel('\u25cf'), findsNothing);
      semantics.dispose();
    });

    testWidgets('every action on the disclosure step has a >= 48dp touch '
        'target', (tester) async {
      await tester.pumpWidget(
        _scoped(_inOnboardingHost(const SmsAccessDisclosureStep())),
      );
      await tester.pump();

      for (final finder in [
        find.byType(FilledButton),
        find.byType(TextButton),
      ]) {
        for (final element in finder.evaluate()) {
          final size = tester.getSize(
            find.byWidget(element.widget, skipOffstage: false),
          );
          expect(size.height, greaterThanOrEqualTo(48));
          expect(size.width, greaterThanOrEqualTo(48));
        }
      }
    });
  });
}

final class _FixedGateway implements SmsPermissionGateway {
  _FixedGateway(this.status);

  final SmsPermissionStatus status;

  @override
  Future<SmsPermissionStatus> current() async => status;

  @override
  Future<SmsPermissionStatus> request() async => status;

  @override
  Future<void> openAppSettings() async {}
}

final class _NeverCompletingGateway implements SmsPermissionGateway {
  @override
  Future<SmsPermissionStatus> current() =>
      Completer<SmsPermissionStatus>().future;

  @override
  Future<SmsPermissionStatus> request() =>
      Completer<SmsPermissionStatus>().future;

  @override
  Future<void> openAppSettings() async {}
}

final class _ThrowingGateway implements SmsPermissionGateway {
  @override
  Future<SmsPermissionStatus> current() async =>
      throw StateError('platform channel unavailable');

  @override
  Future<SmsPermissionStatus> request() async =>
      throw StateError('platform channel unavailable');

  @override
  Future<void> openAppSettings() async {}
}

final class _FixedNotificationGateway implements NotificationPermissionGateway {
  _FixedNotificationGateway(this.status);

  final NotificationPermissionStatus status;

  @override
  Future<NotificationPermissionStatus> current() async => status;

  @override
  Future<NotificationPermissionStatus> request() async => status;

  @override
  Future<void> openAppSettings() async {}
}

final class _NeverCompletingNotificationGateway
    implements NotificationPermissionGateway {
  @override
  Future<NotificationPermissionStatus> current() =>
      Completer<NotificationPermissionStatus>().future;

  @override
  Future<NotificationPermissionStatus> request() =>
      Completer<NotificationPermissionStatus>().future;

  @override
  Future<void> openAppSettings() async {}
}

final class _ThrowingNotificationGateway
    implements NotificationPermissionGateway {
  @override
  Future<NotificationPermissionStatus> current() async =>
      throw StateError('platform channel unavailable');

  @override
  Future<NotificationPermissionStatus> request() async =>
      throw StateError('platform channel unavailable');

  @override
  Future<void> openAppSettings() async {}
}
