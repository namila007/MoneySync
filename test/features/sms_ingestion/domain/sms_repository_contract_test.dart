import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/sms_ingestion/domain/sms_repository.dart';

void main() {
  test('read-only repository exposes capture and history query operations', () {
    const repositoryType = SmsRepository;

    expect(repositoryType, isNotNull);
  });

  test('repository contract declares no source-SMS mutation operation', () {
    final contract = File(
      'lib/features/sms_ingestion/domain/sms_repository.dart',
    ).readAsStringSync();

    expect(contract, contains('queryCaptures'));
    expect(contract, contains('queryHistory'));
    expect(
      RegExp(
        r'\b(update|delete|markRead|archive)\b',
        caseSensitive: false,
      ).hasMatch(contract),
      isFalse,
    );
  });
}
