import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';

final configurationProvider = FutureProvider<ConfigurationState?>((ref) async {
  try {
    final repo = ref.watch(configurationRepositoryProvider).requireValue;
    return await repo.load();
  } catch (_) {
    return null;
  }
});
