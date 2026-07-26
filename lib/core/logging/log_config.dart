import 'package:money_sync/bootstrap/production_policy.dart';

final class LogConfig {
  const LogConfig({
    required this.flavor,
    required this.enableDebugLog,
    required this.safeLogPolicy,
  });

  final String flavor;
  final bool enableDebugLog;
  final SafeLogPolicy safeLogPolicy;
}
