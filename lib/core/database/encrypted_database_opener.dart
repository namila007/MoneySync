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

    final keyHex = handle.id;
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
