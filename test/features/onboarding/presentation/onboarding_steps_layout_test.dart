import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/onboarding/presentation/steps/sms_access_decision_step.dart';
import 'package:money_sync/features/onboarding/presentation/steps/sms_access_disclosure_step.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

/// Mirrors the host that `OnboardingPage` builds around every step:
/// `Expanded > SingleChildScrollView > step`. The scroll view hands the step an
/// unbounded height, so a step that puts a flex child directly in its own
/// Column fails to lay out and renders nothing.
///
/// See onboarding_page.dart:41-59.
Widget _inOnboardingHost(Widget step) {
  return MaterialApp(
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

Widget _scoped(Widget child, {SmsPermissionGateway? gateway}) {
  return ProviderScope(
    overrides: [
      if (gateway != null)
        smsPermissionGatewayProvider.overrideWithValue(gateway),
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
