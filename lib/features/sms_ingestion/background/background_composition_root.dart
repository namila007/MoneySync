import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/database/encrypted_database_opener.dart';
import 'package:money_sync/core/security/database_key_provider.dart';
import 'package:money_sync/core/security/keystore_database_key_provider.dart';
import 'package:money_sync/core/security/native_security_channel.dart';
import 'package:money_sync/features/notifications/data/flutter_local_notifications_service.dart';
import 'package:money_sync/features/notifications/domain/notification_service.dart';
import 'package:money_sync/features/sms_ingestion/data/native_source_identity_signer.dart';
import 'package:money_sync/features/sms_ingestion/data/sms_history_pigeon.g.dart';
import 'package:money_sync/features/sms_ingestion/domain/scan_tracked_senders.dart';
import 'package:money_sync/features/sms_tracking/data/drift_tracked_senders_repository.dart';
import 'package:money_sync/features/transaction_parser/data/rule_pack_registry_repository.dart';

/// Builds an isolate-local [ScanTrackedSenders] instance for background
/// execution. Each call opens its own encrypted database connection and
/// notification service — nothing is shared with the foreground engine.
///
/// In tests, call [buildFromDatabase] to inject an in-memory database and
/// skip the platform-dependent opener.
class BackgroundCompositionRoot {
  BackgroundCompositionRoot({
    NativeSecurityChannel? channel,
    this._keyProvider,
    this._notificationService,
  }) : _channel = channel ?? const NativeSecurityChannel();

  final NativeSecurityChannel _channel;
  final DatabaseKeyProvider? _keyProvider;
  final NotificationService? _notificationService;

  /// Opens a fresh encrypted database, sets WAL + busy_timeout, and
  /// wires all dependencies into [ScanTrackedSenders].
  Future<ScanTrackedSenders> build() async {
    final keyProvider =
        _keyProvider ?? WrappedDatabaseKeyProvider(channel: _channel);
    final opener = ProductionEncryptedDatabaseOpener(
      channel: _channel,
      keyProvider: keyProvider,
    );
    final db = await opener.open();
    await _configureDatabase(db);
    return _buildFromDatabase(db);
  }

  /// Builds [ScanTrackedSenders] from an already-opened [AppDatabase].
  /// Use in tests to inject an in-memory database.
  Future<ScanTrackedSenders> buildFromDatabase(AppDatabase db) async {
    return _buildFromDatabase(db);
  }

  Future<ScanTrackedSenders> _buildFromDatabase(AppDatabase db) async {
    final notifications =
        _notificationService ?? await _createNotificationService();

    final signer = NativeSourceIdentitySigner(channel: _channel).digest;
    final registry = await RulePackRegistryRepository(
      database: db,
    ).loadActiveRegistry();

    return ScanTrackedSenders(
      database: db,
      smsHistoryApi: SmsHistoryHostApi(),
      registry: registry,
      identitySigner: signer,
      notificationService: notifications,
      trackedSendersRepository: DriftTrackedSendersRepository(database: db),
    );
  }

  Future<NotificationService> _createNotificationService() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final service = FlutterLocalNotificationsService(plugin: plugin);
    await service.initialize(androidDefaultIcon: '@mipmap/ic_launcher');
    return service;
  }

  Future<void> _configureDatabase(AppDatabase db) async {
    await db.customStatement('PRAGMA journal_mode = WAL');
    await db.customStatement('PRAGMA busy_timeout = 5000');
  }
}
