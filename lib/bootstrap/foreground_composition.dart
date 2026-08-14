import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/app/app.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/bootstrap/startup_state.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/database/database_health.dart';
import 'package:money_sync/core/logging/activity_event_writer.dart';
import 'package:money_sync/core/logging/activity_writer_generation.dart';
import 'package:money_sync/core/privacy/clear_local_data.dart';
import 'package:money_sync/core/privacy/log_redaction_policy.dart';
import 'package:money_sync/core/security/foreground_lock.dart';
import 'package:money_sync/features/data_control/application/clear_local_data.dart'
    as data_control;
import 'package:money_sync/features/data_control/presentation/data_control_controller.dart';
import 'package:money_sync/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:money_sync/features/settings/data/drift_configuration_repository.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

final configurationRepositoryProvider = FutureProvider<ConfigurationRepository>(
  (ref) async {
    final db = await ref.watch(appDatabaseProvider.future);
    return DriftConfigurationRepository(database: db);
  },
);

Future<void> _initActivityEventWriter(
  AppDatabase db,
  ActivityWriterGeneration generation,
) async {
  final redaction = const LogRedactionPolicy();
  final activityWriter = ActivityEventWriter(
    database: db,
    redaction: redaction,
    privacyEpochProvider: () => _loadPrivacyEpoch(db),
    generation: generation,
  );
  Logger(
    'app.info',
  ).onRecord.listen((record) => activityWriter.writeFromLogRecord(record));
  Logger.root.onRecord.listen(
    (record) => activityWriter.writeFromLogRecord(record),
  );
  Logger.root.onRecord.listen((record) {
    debugPrint('[${record.loggerName}] ${record.message}');
  });
}

Future<int> _loadPrivacyEpoch(AppDatabase db) async {
  try {
    final result = await db
        .customSelect(
          'SELECT privacy_epoch FROM app_settings WHERE singleton_id = 1',
        )
        .get();
    if (result.isNotEmpty) {
      return result.first.data['privacy_epoch'] as int;
    }
  } on Exception {
    // best-effort
  }
  return 0;
}

class BootstrapGate extends ConsumerWidget {
  const BootstrapGate({super.key, required this.config});
  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbAsync = ref.watch(appDatabaseProvider);
    final body = dbAsync.when(
      data: (db) => _AwaitingStartup(config: config),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Logger('bootstrap').severe('Database open failed: $e', e, s);
        });
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not open local data'),
                const SizedBox(height: 8),
                Text(
                  'Error: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: () {}, child: const Text('Try again')),
              ],
            ),
          ),
        );
      },
    );
    return Directionality(textDirection: TextDirection.ltr, child: body);
  }
}

class _AwaitingStartup extends ConsumerStatefulWidget {
  const _AwaitingStartup({required this.config});
  final AppConfig config;
  @override
  ConsumerState<_AwaitingStartup> createState() => _AwaitingStartupState();
}

class _AwaitingStartupState extends ConsumerState<_AwaitingStartup>
    with WidgetsBindingObserver {
  data_control.ClearLocalDataUseCase? _useCase;
  final _activityGeneration = ActivityWriterGeneration();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wireActivityWriter();
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(foregroundLockControllerProvider.notifier).onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(smsPermissionStatusProvider.notifier).refresh();
    }
  }

  Future<void> _wireActivityWriter() async {
    try {
      final db = await ref.read(appDatabaseProvider.future);
      await _initActivityEventWriter(db, _activityGeneration);
      Logger('bootstrap').info('ActivityEvent writer wired to DB');
    } on Exception {
      // DB not available — ActivityEvent writer deferred
    }
  }

  Future<void> _initialize() async {
    final log = Logger('startup');
    log.info('Starting startup initialization');
    final startupNotifier = ref.read(startupStateProvider.notifier);
    final db = await ref.read(appDatabaseProvider.future);
    final healthRepo = DatabaseHealthRepository(database: db);
    final onboardingRepo = DriftOnboardingRepository(database: db);

    final channel = ref.read(nativeSecurityChannelProvider);
    final databasePath = await channel.getSensitiveDatabasePath();
    final clearService = ClearLocalDataService(
      database: db,
      channel: channel,
      databasePath: databasePath,
      activityGeneration: _activityGeneration,
    );
    _useCase = data_control.ClearLocalDataUseCase(
      database: db,
      clearLocalDataService: clearService,
    );

    log.info('Health check and onboarding repo ready');
    await startupNotifier.initialize(
      healthRepo: healthRepo,
      onboardingRepo: onboardingRepo,
    );
    log.info(
      'Startup init done, status=${ref.read(startupStateProvider).status.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupStateProvider);

    if (state.status == StartupStatus.onboardingRequired) {
      return _appWithOverrides();
    }
    if (state.status == StartupStatus.ready) {
      return _appWithOverrides();
    }
    if (state.status == StartupStatus.recoveryRequired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Logger(
          'startup',
        ).severe('Recovery required: ${state.health?.safeCode ?? "UNKNOWN"}');
      });
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('MoneySync could not open local data'),
                const SizedBox(height: 8),
                Text('Safe code: ${state.health?.safeCode ?? "UNKNOWN"}'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _initialize,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _appWithOverrides() {
    final useCase = _useCase;
    if (useCase == null) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    // smsPermissionGatewayProvider is deliberately NOT overridden here: it must
    // be hosted by the root container in bootstrap.dart, because the notifier
    // that reads it is not scoped to this ProviderScope and would otherwise
    // resolve the root's throwing default.
    final overrides = [
      clearLocalDataUseCaseProvider.overrideWithValue(useCase),
    ];
    return ProviderScope(overrides: overrides, child: const MoneySyncApp());
  }
}
