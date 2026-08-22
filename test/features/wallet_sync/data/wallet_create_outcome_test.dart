import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_outcome.dart';

void main() {
  group('wallet create outcome value semantics (M5.6/M5.13)', () {
    test('WalletItemSucceeded rejects an empty record id', () {
      expect(() => WalletItemSucceeded(recordId: ''), throwsArgumentError);
      final ok = WalletItemSucceeded(recordId: 'record-1');
      expect(ok.recordId, 'record-1');
    });

    test('WalletItemFailed carries a safe error code', () {
      const failed = WalletItemFailed(safeErrorCode: 'field_error');
      expect(failed.safeErrorCode, 'field_error');
    });

    test('WalletCreatePartial keeps an immutable item list', () {
      final partial = WalletCreatePartial(
        items: [
          WalletItemSucceeded(recordId: 'a'),
          const WalletItemFailed(safeErrorCode: 'b'),
        ],
      );
      expect(partial.items, hasLength(2));
      expect(
        () => partial.items.add(const WalletItemFailed(safeErrorCode: 'x')),
        throwsUnsupportedError,
      );
    });
  });
}
