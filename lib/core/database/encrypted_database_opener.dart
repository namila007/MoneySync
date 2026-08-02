import 'dart:io';

import 'package:drift/native.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/security/database_key_provider.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

final class CipherVersionException implements Exception {
  const CipherVersionException();
}

final class ProductionEncryptedDatabaseOpener {
  ProductionEncryptedDatabaseOpener({
    required this.channel,
    required this.keyProvider,
  });

  final NativeSecurityChannel channel;
  final DatabaseKeyProvider keyProvider;

  Future<AppDatabase> open() async {
    final path = await channel.getSensitiveDatabasePath();
    final keyAccess = await keyProvider.acquire();
    final handle = keyAccess.requireKey();

    // The sqlite3(+SQLCipher) package this project uses only exposes keying
    // via `PRAGMA key` executed from Dart — there is no raw-bytes keying API,
    // and Kotlin must never open the Drift database (AGENTS.md). Drift's
    // NativeDatabase `setup` callback also runs lazily on first query, not at
    // construction time, so the raw Uint8List cannot be zeroized until after
    // `setup` runs. The minimized-exposure boundary is therefore: consume the
    // raw bytes exactly once, right here, to build a transient hex string;
    // zeroize the bytes immediately; capture only the hex string in the
    // closure (same lifetime the previous implementation already had). See
    // docs/adr/0001-native-database-key-boundary.md.
    final keyHex = handle.useAndDispose(
      (bytes) => bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    );
    final db = NativeDatabase(
      File(path),
      setup: (database) {
        database.execute("PRAGMA key = \"x'$keyHex'\";");
        final version = database.select("PRAGMA cipher_version;");
        if (version.isEmpty) {
          throw const CipherVersionException();
        }
      },
    );

    return AppDatabase(db);
  }
}

final class InMemoryDatabaseOpener {
  const InMemoryDatabaseOpener();
  AppDatabase open() => AppDatabase.inMemoryForTesting();
}
