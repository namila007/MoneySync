import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_outcome.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutation_failure.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_repository.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';

import '../../../helpers/fake_wallet_api_data_source.dart';

void main() {
  TransactionCandidateSnapshot snapshot() => TransactionCandidateSnapshot(
    accountId: 'account-1',
    amountMinor: -4500,
    currencyCode: 'LKR',
    recordDateUtc: DateTime.utc(2026, 7, 18, 10, 42),
    paymentType: WalletPaymentType.creditCard,
    recordState: WalletRecordState.cleared,
  );

  group('WalletRepository.create', () {
    test('maps all-succeeded outcome to remote success with record id', () async {
      final dataSource = FakeWalletApiDataSource(
        createOutcome: const WalletCreateAllSucceeded(recordId: 'record-9'),
      );
      final repository = WalletRepository(dataSource: dataSource);

      final result = await repository.create(snapshot());

      expect(result, isA<WalletMutationRemoteSuccess>());
      expect((result as WalletMutationRemoteSuccess).remoteRecordId, 'record-9');
      expect((result).statusCode, 200);
      expect(dataSource.createCalls, 1);
      expect(dataSource.lastCreatePayload!.accountId, 'account-1');
    });

    test('maps a single succeeded 207 item to remote success', () async {
      final dataSource = FakeWalletApiDataSource(
        createOutcome: WalletCreatePartial(
          items: [
            WalletItemSucceeded(recordId: 'record-207'),
          ],
        ),
      );
      final repository = WalletRepository(dataSource: dataSource);

      final result = await repository.create(snapshot());

      expect(result, isA<WalletMutationRemoteSuccess>());
      expect((result as WalletMutationRemoteSuccess).remoteRecordId, 'record-207');
      expect(result.statusCode, 207);
    });

    test('maps an all-failed 207 batch to pre-transmission failure', () async {
      final dataSource = FakeWalletApiDataSource(
        createOutcome: WalletCreatePartial(
          items: [
            const WalletItemFailed(safeErrorCode: 'field_error'),
          ],
        ),
      );
      final repository = WalletRepository(dataSource: dataSource);

      final result = await repository.create(snapshot());

      expect(result, isA<WalletMutationPreTransmissionFailure>());
    });

    test('maps ambiguous post-transmission error to ambiguity', () async {
      final dataSource = FakeWalletApiDataSource(
        error: const WalletApiDataSourceException(
          AmbiguousPostTransmission(),
        ),
      );
      final repository = WalletRepository(dataSource: dataSource);

      final result = await repository.create(snapshot());

      expect(result, isA<WalletMutationPostTransmissionAmbiguity>());
    });

    test('maps permanent client failure to client failure', () async {
      final dataSource = FakeWalletApiDataSource(
        error: const WalletApiDataSourceException(
          PermanentClientFailure(),
        ),
      );
      final repository = WalletRepository(dataSource: dataSource);

      final result = await repository.create(snapshot());

      expect(result, isA<WalletMutationClientFailure>());
    });

    test('maps retryable server failure to server failure', () async {
      final dataSource = FakeWalletApiDataSource(
        error: const WalletApiDataSourceException(RetryableConflict()),
      );
      final repository = WalletRepository(dataSource: dataSource);

      final result = await repository.create(snapshot());

      expect(result, isA<WalletMutationServerFailure>());
    });
  });

  group('WalletRepository read/reconcile/usage', () {
    test('delegates getRecord', () async {
      final dataSource = FakeWalletApiDataSource(
        record: const WalletRecordRead(
          id: 'record-1',
          amountMinor: -4500,
          currencyCode: 'LKR',
        ),
      );
      final repository = WalletRepository(dataSource: dataSource);

      final record = await repository.getRecord('record-1');

      expect(dataSource.getRecordCalls, 1);
      expect(record!.id, 'record-1');
    });

    test('delegates reconciliation lookup with marker query', () async {
      final dataSource = FakeWalletApiDataSource(
        reconciliationResults: const [
          WalletRecordRead(
            id: 'record-1',
            amountMinor: -4500,
            currencyCode: 'LKR',
          ),
        ],
      );
      final repository = WalletRepository(dataSource: dataSource);

      final results = await repository.findRecordForReconciliation(
        const WalletReconciliationQuery(
          marker: '7K2M9P4D8Q6R1V3X5T0Z',
          accountId: 'account-1',
          amountMinor: -4500,
        ),
      );

      expect(dataSource.reconciliationCalls, 1);
      expect(results, hasLength(1));
    });

    test('delegates usage stats', () async {
      final dataSource = FakeWalletApiDataSource(
        usageStats: const WalletUsageStats(
          recordCount: 42,
          requestCount: 100,
          rateLimitRemaining: 58,
        ),
      );
      final repository = WalletRepository(dataSource: dataSource);

      final stats = await repository.getUsageStats();

      expect(dataSource.usageStatsCalls, 1);
      expect(stats.recordCount, 42);
    });
  });
}
