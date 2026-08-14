import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/features/sms_tracking/data/drift_tracked_senders_repository.dart';
import 'package:money_sync/features/sms_tracking/domain/tracked_senders.dart';

final trackedSendersRepositoryProvider =
    FutureProvider<TrackedSendersRepository>((ref) async {
      final db = await ref.watch(appDatabaseProvider.future);
      return DriftTrackedSendersRepository(database: db);
    });

final trackedSendersProvider = FutureProvider<List<TrackedSender>>((ref) async {
  final repo = await ref.watch(trackedSendersRepositoryProvider.future);
  return repo.load();
});

class TrackedSendersController extends Notifier<AsyncValue<List<String>>> {
  @override
  AsyncValue<List<String>> build() {
    final repoAsync = ref.watch(trackedSendersRepositoryProvider);
    repoAsync.whenData((repo) => _load(repo));
    return const AsyncValue.loading();
  }

  Future<void> _load(TrackedSendersRepository repo) async {
    try {
      final senders = await repo.load();
      state = AsyncValue.data([for (final s in senders) s.address]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void toggle(String address) {
    final current = state.value ?? const <String>[];
    if (current.contains(address)) {
      state = AsyncValue.data(current.where((a) => a != address).toList());
    } else {
      state = AsyncValue.data([...current, address]);
    }
  }

  Future<UpdateTrackedSendersResult> save() async {
    final repo = await ref.read(trackedSendersRepositoryProvider.future);
    final useCase = UpdateTrackedSenders(repository: repo);
    final result = await useCase(state.value ?? const []);
    if (result is TrackedSendersUpdated) {
      state = AsyncValue.data(result.senders);
    }
    return result;
  }
}

final trackedSendersControllerProvider =
    NotifierProvider<TrackedSendersController, AsyncValue<List<String>>>(
      TrackedSendersController.new,
    );
