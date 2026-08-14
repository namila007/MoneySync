import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/sms_tracking/domain/tracked_senders.dart';

final class _FakeRepo implements TrackedSendersRepository {
  List<String> saved = const [];

  @override
  Future<List<TrackedSender>> load() async => const [];

  @override
  Future<void> save(List<String> addresses) async {
    saved = addresses;
  }
}

void main() {
  group('UpdateTrackedSenders', () {
    test('trims and dedupes addresses, preserving order', () async {
      final repo = _FakeRepo();
      final useCase = UpdateTrackedSenders(repository: repo);

      final result = await useCase([' SAMPATHTX ', 'SAMPATHTX', 'NATIONS_SMS']);

      expect(result, isA<TrackedSendersUpdated>());
      expect((result as TrackedSendersUpdated).senders, [
        'SAMPATHTX',
        'NATIONS_SMS',
      ]);
      expect(repo.saved, ['SAMPATHTX', 'NATIONS_SMS']);
    });

    test('rejects blank entries', () async {
      final repo = _FakeRepo();
      final useCase = UpdateTrackedSenders(repository: repo);

      final result = await useCase(['   ']);

      expect(result, isA<TrackedSendersRejected>());
      expect(
        (result as TrackedSendersRejected).reason,
        TrackedSendersRejection.invalidEntry,
      );
      expect(repo.saved, isEmpty);
    });

    test('rejects empty input list', () async {
      final repo = _FakeRepo();
      final useCase = UpdateTrackedSenders(repository: repo);

      final result = await useCase(const []);

      expect(result, isA<TrackedSendersRejected>());
      expect(
        (result as TrackedSendersRejected).reason,
        TrackedSendersRejection.emptyInput,
      );
      expect(repo.saved, isEmpty);
    });

    test('rejects invalid (too long) entries', () async {
      final repo = _FakeRepo();
      final useCase = UpdateTrackedSenders(repository: repo);

      final result = await useCase(['OK', 'X' * 33]);

      expect(result, isA<TrackedSendersRejected>());
      expect(
        (result as TrackedSendersRejected).reason,
        TrackedSendersRejection.invalidEntry,
      );
      expect(repo.saved, isEmpty);
    });

    test('rejects more than kMaxTrackedSenders', () async {
      final repo = _FakeRepo();
      final useCase = UpdateTrackedSenders(repository: repo);

      final result = await useCase([
        for (var i = 0; i <= kMaxTrackedSenders; i++) 'SENDER_$i',
      ]);

      expect(result, isA<TrackedSendersRejected>());
      expect(
        (result as TrackedSendersRejected).reason,
        TrackedSendersRejection.tooMany,
      );
      expect(repo.saved, isEmpty);
    });

    test('accepts exactly kMaxTrackedSenders', () async {
      final repo = _FakeRepo();
      final useCase = UpdateTrackedSenders(repository: repo);

      final result = await useCase([
        for (var i = 0; i < kMaxTrackedSenders; i++) 'SENDER_$i',
      ]);

      expect(result, isA<TrackedSendersUpdated>());
      expect(
        (result as TrackedSendersUpdated).senders.length,
        kMaxTrackedSenders,
      );
    });

    test('persists via repository on success', () async {
      final repo = _FakeRepo();
      final useCase = UpdateTrackedSenders(repository: repo);

      await useCase(['SAMPATHTX']);

      expect(repo.saved, ['SAMPATHTX']);
    });
  });

  group('TrackedSendersQuery', () {
    test('encodes and decodes addresses round-trip', () {
      final encoded = TrackedSendersQuery.encode(['A', 'B']);
      expect(TrackedSendersQuery.decode(encoded), ['A', 'B']);
    });

    test('decode fails closed on null, empty, malformed, and non-list', () {
      expect(TrackedSendersQuery.decode(null), isEmpty);
      expect(TrackedSendersQuery.decode(''), isEmpty);
      expect(TrackedSendersQuery.decode('not-json'), isEmpty);
      expect(TrackedSendersQuery.decode('{"x":1}'), isEmpty);
    });

    test('decode filters non-string entries', () {
      expect(TrackedSendersQuery.decode('["A", 1, null]'), ['A']);
    });
  });

  group('TrackedSender', () {
    test('rejects empty and over-long addresses', () {
      expect(
        () => TrackedSender.create('', addedAtEpochMs: 1),
        throwsArgumentError,
      );
      expect(
        () => TrackedSender.create('X' * 33, addedAtEpochMs: 1),
        throwsArgumentError,
      );
      expect(
        TrackedSender.create(' SAMPATH ', addedAtEpochMs: 1).address,
        'SAMPATH',
      );
    });
  });
}
