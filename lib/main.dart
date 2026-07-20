import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/bootstrap.dart';

/// The unqualified entry point is the permission-free safe default.
///
/// Flavor builds use their matching explicit entry points instead.
void main() => bootstrap(const AppConfig.playManual());
