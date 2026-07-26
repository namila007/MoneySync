import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/database/encrypted_database_opener.dart';

enum DatabaseHealthStatus {
  ready,
  cipherUnavailable,
  keyUnavailable,
  corrupt,
  migrationFailed,
  deletionIncomplete,
}

final class DatabaseHealth {
  const DatabaseHealth({required this.status, this.safeCode});
  final DatabaseHealthStatus status;
  final String? safeCode;
}

final class DatabaseHealthRepository {
  DatabaseHealthRepository({required this.database});

  final AppDatabase database;

  Future<DatabaseHealth> check() async {
    try {
      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND "
            "name NOT LIKE 'sqlite_%'",
          )
          .get();
      if (tables.isEmpty) {
        return const DatabaseHealth(
          status: DatabaseHealthStatus.corrupt,
          safeCode: 'EMPTY_SCHEMA',
        );
      }
      return const DatabaseHealth(
        status: DatabaseHealthStatus.ready,
        safeCode: null,
      );
    } on CipherVersionException {
      return const DatabaseHealth(
        status: DatabaseHealthStatus.cipherUnavailable,
        safeCode: 'CIPHER_UNSUPPORTED',
      );
    } catch (_) {
      return const DatabaseHealth(
        status: DatabaseHealthStatus.corrupt,
        safeCode: 'DB_ERROR',
      );
    }
  }
}
