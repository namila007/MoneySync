import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/core/time/clock.dart';
import 'package:money_sync/core/time/id_generator.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  throw StateError('AppConfig must be supplied by the composition root.');
});

final appCapabilitiesProvider = Provider<AppCapabilities>((ref) {
  return ref.watch(appConfigProvider).capabilities;
});

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final idGeneratorProvider = Provider<IdGenerator>((ref) {
  return DeterministicIdGenerator(prefix: 'runtime');
});
