import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

/// M5.22 WP-G. A group is not an assignable category: the Wallet API requires
/// `categoryId` to be a real category id (verified against the live API,
/// 2026-08-25). The picker used to send a `groupId`, which matched no category,
/// so the button silently fell back to "Uncategorized" and the value would have
/// been rejected on create.
///
/// Every group instead owns a general base category identified by
/// `<groupId>__general` — that is what "All [Group]" must resolve to.
void main() {
  WalletCategory category({
    required String id,
    required String name,
    String groupId = 'food_and_drinks',
    String? systemId,
    bool custom = false,
    String? parentId,
  }) => WalletCategory(
    id: id,
    name: name,
    groupId: groupId,
    groupName: 'Food & Drinks',
    systemId: systemId,
    customCategory: custom,
    parentId: parentId,
  );

  test('the general category represents its whole group', () {
    final general = category(
      id: '5c5c03eb-000a-8000-8000-000000000000',
      name: 'Food & Drinks',
      systemId: 'food_and_drinks__general',
    );
    expect(general.isGroupGeneral, isTrue);
  });

  test('an ordinary base category does not represent the group', () {
    final groceries = category(
      id: '5c5c03e8-000a-8000-8000-000000000000',
      name: 'Groceries',
      systemId: 'food_and_drinks__groceries',
    );
    expect(groceries.isGroupGeneral, isFalse);
  });

  test('a custom category has no slug and never represents the group', () {
    final custom = category(
      id: '5e6bfb01-e747-4621-973d-c179a9f28f41',
      name: 'KFC',
      custom: true,
      parentId: '5c5c03e9-000a-8000-8000-000000000000',
    );
    expect(custom.systemId, isNull);
    expect(custom.isGroupGeneral, isFalse);
  });

  test('a slug from a different group does not match', () {
    // Guards against a prefix/substring comparison: this slug ends in
    // "__general" but belongs to another group entirely.
    final other = category(
      id: 'other-1',
      name: 'Housing',
      systemId: 'housing__general',
    );
    expect(other.isGroupGeneral, isFalse);
  });
}
