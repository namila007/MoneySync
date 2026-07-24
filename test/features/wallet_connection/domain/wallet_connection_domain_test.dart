import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';

void main() {
  group('WalletToken', () {
    test('accepts opaque tokens without retaining a printable secret', () {
      final token = WalletToken.parse('synthetic-token_123');

      expect(token.toString(), 'WalletToken(***)');
      expect('$token', isNot(contains('synthetic-token_123')));
    });

    test('rejects unsafe token input', () {
      for (final value in <String>[
        '',
        ' token',
        'token ',
        'line\nbreak',
        'tab\tvalue',
        'x' * 8193,
      ]) {
        expect(() => WalletToken.parse(value), throwsFormatException);
      }
    });
  });

  group('WalletAccount eligibility', () {
    test('is deterministic and keeps foreign currency review only', () {
      final base = WalletAccount(
        id: 'account-1',
        name: 'Daily',
        currencyCode: 'LKR',
        isArchived: false,
        isBankSynced: false,
        isWritable: true,
      );

      expect(base.eligibility, WalletAccountEligibility.eligible);
      expect(
        base.copyWith(isArchived: true).eligibility,
        WalletAccountEligibility.archived,
      );
      expect(
        base.copyWith(isBankSynced: true).eligibility,
        WalletAccountEligibility.bankSynced,
      );
      expect(
        base.copyWith(isWritable: false).eligibility,
        WalletAccountEligibility.unwritable,
      );
      expect(
        base.copyWith(currencyCode: 'USD').eligibility,
        WalletAccountEligibility.foreignCurrencyReviewOnly,
      );
      expect(
        WalletAccount(
          id: '',
          name: '',
          currencyCode: '',
          isArchived: false,
          isBankSynced: false,
          isWritable: true,
        ).eligibility,
        WalletAccountEligibility.missingRequiredFields,
      );
    });
  });

  test(
    'wallet failure descriptions never disclose supplied internal detail',
    () {
      const failure = WalletReadFailure.invalidToken();
      expect(failure.toString(), isNot(contains('token')));
      expect(failure.userMessage, contains('Wallet connection'));
    },
  );

  test('catalog snapshots caller-owned account and category lists', () {
    final accounts = [
      const WalletAccount(
        id: 'account-1',
        name: 'Daily',
        currencyCode: 'LKR',
        isArchived: false,
        isBankSynced: false,
        isWritable: false,
      ),
    ];
    final categories = [const WalletCategory(id: 'category-1', name: 'Food')];
    final catalog = WalletCatalog(accounts: accounts, categories: categories);
    accounts.clear();
    categories.clear();

    expect(catalog.accounts, hasLength(1));
    expect(catalog.categories, hasLength(1));
    expect(
      () => catalog.accounts.add(catalog.accounts.single),
      throwsUnsupportedError,
    );
  });

  test('page and catalog value objects preserve all optional branches', () {
    final account =
        const WalletAccount(
          id: 'one',
          name: 'One',
          currencyCode: 'LKR',
          isArchived: false,
          isBankSynced: false,
          isWritable: true,
        ).copyWith(
          id: 'two',
          name: 'Two',
          currencyCode: 'USD',
          isArchived: true,
          isBankSynced: true,
          isWritable: false,
        );
    final page = WalletPage<WalletAccount>(items: [account], nextOffset: 2);

    expect(account.id, 'two');
    expect(account.name, 'Two');
    expect(account.currencyCode, 'USD');
    expect(account.isArchived, isTrue);
    expect(account.isBankSynced, isTrue);
    expect(account.isWritable, isFalse);
    expect(page.nextOffset, 2);
  });

  test('every typed failure maps to a fixed safe user message', () {
    const failures = <WalletReadFailure>[
      WalletReadFailure.invalidToken(),
      WalletReadFailure.initialSyncInProgress(),
      WalletReadFailure.rateLimited(retryAfterSeconds: 1),
      WalletReadFailure.offline(),
      WalletReadFailure.timeout(),
      WalletReadFailure.tls(),
      WalletReadFailure.service(),
      WalletReadFailure.protocol(),
    ];

    for (final failure in failures) {
      expect(failure.userMessage, isNotEmpty);
      expect(failure.toString(), isNot(contains('synthetic-token')));
    }
  });
}
