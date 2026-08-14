import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/settings/application/update_history_import.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';

void main() {
  group('UpdateHistoryImport', () {
    const allGatesOpen = UpdateHistoryImport(
      isCapabilityAvailable: true,
      isPermissionGranted: true,
      isDisclosureAccepted: true,
    );

    test('accepts default preferences', () {
      const prefs = HistoryImportPreferences();
      final result = allGatesOpen.call(prefs);
      expect(result, isA<HistoryImportUpdated>());
      expect((result as HistoryImportUpdated).applied.windowDays, 7);
      expect(result.applied.messageCap, 100);
    });

    test('rejects windowDays < 1', () {
      const prefs = HistoryImportPreferences(windowDays: 0);
      final result = allGatesOpen.call(prefs);
      expect(result, isA<HistoryImportRejected>());
      expect(
        (result as HistoryImportRejected).reason,
        HistoryImportRejectionReason.windowOutOfRange,
      );
    });

    test('rejects windowDays > 90', () {
      const prefs = HistoryImportPreferences(windowDays: 91);
      final result = allGatesOpen.call(prefs);
      expect(result, isA<HistoryImportRejected>());
      expect(
        (result as HistoryImportRejected).reason,
        HistoryImportRejectionReason.windowOutOfRange,
      );
    });

    test('accepts window boundary values 1 and 90', () {
      for (final days in [1, 90]) {
        final result = allGatesOpen.call(
          HistoryImportPreferences(windowDays: days),
        );
        expect(result, isA<HistoryImportUpdated>(), reason: 'days=$days');
      }
    });

    test('rejects cap > kHistoryHardCap', () {
      const prefs = HistoryImportPreferences(messageCap: 501);
      final result = allGatesOpen.call(prefs);
      expect(result, isA<HistoryImportRejected>());
      expect(
        (result as HistoryImportRejected).reason,
        HistoryImportRejectionReason.capOutOfRange,
      );
    });

    test('rejects cap < 1', () {
      const prefs = HistoryImportPreferences(messageCap: 0);
      final result = allGatesOpen.call(prefs);
      expect(result, isA<HistoryImportRejected>());
      expect(
        (result as HistoryImportRejected).reason,
        HistoryImportRejectionReason.capOutOfRange,
      );
    });

    test('accepts presets 3/7/14', () {
      for (final days in kHistoryWindowPresets) {
        final result = allGatesOpen.call(
          HistoryImportPreferences(windowDays: days),
        );
        expect(result, isA<HistoryImportUpdated>(), reason: 'preset=$days');
      }
    });

    test('rejects enabled=true when capability unavailable', () {
      const useCase = UpdateHistoryImport(
        isCapabilityAvailable: false,
        isPermissionGranted: true,
        isDisclosureAccepted: true,
      );
      const prefs = HistoryImportPreferences(enabled: true);
      final result = useCase.call(prefs);
      expect(result, isA<HistoryImportRejected>());
      expect(
        (result as HistoryImportRejected).reason,
        HistoryImportRejectionReason.capabilityUnavailable,
      );
    });

    test('rejects enabled=true when permission not granted', () {
      const useCase = UpdateHistoryImport(
        isCapabilityAvailable: true,
        isPermissionGranted: false,
        isDisclosureAccepted: true,
      );
      const prefs = HistoryImportPreferences(enabled: true);
      final result = useCase.call(prefs);
      expect(result, isA<HistoryImportRejected>());
      expect(
        (result as HistoryImportRejected).reason,
        HistoryImportRejectionReason.permissionNotGranted,
      );
    });

    test('rejects enabled=true when disclosure not accepted', () {
      const useCase = UpdateHistoryImport(
        isCapabilityAvailable: true,
        isPermissionGranted: true,
        isDisclosureAccepted: false,
      );
      const prefs = HistoryImportPreferences(enabled: true);
      final result = useCase.call(prefs);
      expect(result, isA<HistoryImportRejected>());
      expect(
        (result as HistoryImportRejected).reason,
        HistoryImportRejectionReason.disclosureNotAccepted,
      );
    });

    test('accepts enabled=true when all gates pass', () {
      const prefs = HistoryImportPreferences(
        windowDays: 7,
        messageCap: 100,
        enabled: true,
      );
      final result = allGatesOpen.call(prefs);
      expect(result, isA<HistoryImportUpdated>());
      expect((result as HistoryImportUpdated).applied.enabled, isTrue);
    });
  });
}
