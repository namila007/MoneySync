import 'package:money_sync/core/security/database_key_provider.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

final class WrappedDatabaseKeyProvider implements DatabaseKeyProvider {
  WrappedDatabaseKeyProvider({required this.channel});
  final NativeSecurityChannel channel;

  @override
  Future<DatabaseKeyAccess> acquire() async {
    try {
      await channel.ensureContentKey();
      final keyBytes = await channel.acquireContentKeyBytes();
      return DatabaseKeyAvailable(DatabaseKeyHandle(keyBytes));
    } on NativeChannelKeyException {
      return const DatabaseKeyUnavailable(DatabaseKeyUnavailableReason.lost);
    } on NativeChannelUnavailableException {
      return const DatabaseKeyUnavailable(DatabaseKeyUnavailableReason.lost);
    }
  }
}
