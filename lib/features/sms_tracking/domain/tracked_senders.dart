import 'dart:convert';

const int kMaxTrackedSenders = 50;
const int kMaxSenderLength = 32;

final class TrackedSender {
  TrackedSender._(this.address, this.addedAtEpochMs);

  factory TrackedSender.create(
    String rawAddress, {
    required int addedAtEpochMs,
  }) {
    final trimmed = rawAddress.trim();
    if (trimmed.isEmpty || trimmed.length > kMaxSenderLength) {
      throw ArgumentError('Invalid sender address.');
    }
    return TrackedSender._(trimmed, addedAtEpochMs);
  }

  final String address;
  final int addedAtEpochMs;
}

abstract interface class TrackedSendersRepository {
  Future<List<TrackedSender>> load();
  Future<void> save(List<String> addresses);
}

sealed class UpdateTrackedSendersResult {
  const UpdateTrackedSendersResult();
}

final class TrackedSendersUpdated extends UpdateTrackedSendersResult {
  const TrackedSendersUpdated(this.senders);
  final List<String> senders;
}

final class TrackedSendersRejected extends UpdateTrackedSendersResult {
  const TrackedSendersRejected(this.reason);
  final TrackedSendersRejection reason;
}

enum TrackedSendersRejection { emptyInput, tooMany, invalidEntry }

final class UpdateTrackedSenders {
  const UpdateTrackedSenders({required this.repository});

  final TrackedSendersRepository repository;

  Future<UpdateTrackedSendersResult> call(List<String> rawAddresses) async {
    final seen = <String>{};
    final senders = <String>[];
    for (final raw in rawAddresses) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty || trimmed.length > kMaxSenderLength) {
        return const TrackedSendersRejected(
          TrackedSendersRejection.invalidEntry,
        );
      }
      if (seen.add(trimmed)) senders.add(trimmed);
    }
    if (senders.isEmpty) {
      return const TrackedSendersRejected(TrackedSendersRejection.emptyInput);
    }
    if (senders.length > kMaxTrackedSenders) {
      return const TrackedSendersRejected(TrackedSendersRejection.tooMany);
    }
    await repository.save(senders);
    return TrackedSendersUpdated(senders);
  }
}

final class TrackedSendersQuery {
  const TrackedSendersQuery(this.addresses);

  final List<String> addresses;

  bool get isEmpty => addresses.isEmpty;

  static String encode(List<String> addresses) => jsonEncode(addresses);

  static List<String> decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.whereType<String>().toList();
    } catch (_) {
      return const [];
    }
  }
}
