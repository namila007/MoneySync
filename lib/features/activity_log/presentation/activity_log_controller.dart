import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/features/activity_log/data/drift_activity_log_repository.dart';
import 'package:money_sync/features/activity_log/domain/activity_log_repository.dart';

/// Awaits the database rather than reading `requireValue`: the database future
/// is still loading on the first frame, and throwing from a provider body
/// during build marks the surrounding scope dirty mid-build.
final activityLogRepositoryProvider = FutureProvider<ActivityLogRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftActivityLogRepository(database: database);
});

final activityLogProvider = FutureProvider<List<ActivityLogEntry>>((ref) async {
  final repository = await ref.watch(activityLogRepositoryProvider.future);
  return repository.recent();
});
