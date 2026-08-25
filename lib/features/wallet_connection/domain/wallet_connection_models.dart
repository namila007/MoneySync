enum WalletAccountEligibility {
  eligible,
  archived,
  bankSynced,
  unwritable,
  missingRequiredFields,
  foreignCurrencyReviewOnly,
}

final class WalletAccount {
  const WalletAccount({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.isArchived,
    required this.isBankSynced,
    required this.isWritable,
  });

  final String id;
  final String name;
  final String currencyCode;
  final bool isArchived;
  final bool isBankSynced;
  final bool isWritable;

  WalletAccountEligibility get eligibility {
    if (id.isEmpty || name.isEmpty || currencyCode.isEmpty) {
      return WalletAccountEligibility.missingRequiredFields;
    }
    if (isArchived) return WalletAccountEligibility.archived;
    if (isBankSynced) return WalletAccountEligibility.bankSynced;
    if (!isWritable) return WalletAccountEligibility.unwritable;
    if (currencyCode.toUpperCase() != 'LKR') {
      return WalletAccountEligibility.foreignCurrencyReviewOnly;
    }
    return WalletAccountEligibility.eligible;
  }

  WalletAccount copyWith({
    String? id,
    String? name,
    String? currencyCode,
    bool? isArchived,
    bool? isBankSynced,
    bool? isWritable,
  }) => WalletAccount(
    id: id ?? this.id,
    name: name ?? this.name,
    currencyCode: currencyCode ?? this.currencyCode,
    isArchived: isArchived ?? this.isArchived,
    isBankSynced: isBankSynced ?? this.isBankSynced,
    isWritable: isWritable ?? this.isWritable,
  );
}

final class WalletCategory {
  const WalletCategory({
    required this.id,
    required this.name,
    required this.groupId,
    required this.groupName,
    this.parentId,
    this.customCategory = false,
    this.cardinality,
    this.systemId,
  });

  final String id;
  final String name;
  final String groupId;
  final String groupName;
  final String? parentId;
  final bool customCategory;
  final String? cardinality;

  /// Wallet registry slug for a base category, e.g. `food_and_drinks__general`.
  /// Null for custom categories, which have no slug.
  final String? systemId;

  /// True when this is the category that represents its whole group.
  ///
  /// A group is not itself assignable (`categoryId` must be a real category
  /// id), but every group owns a general base category, so "All [Group]"
  /// resolves here (M5.22 WP-G).
  bool get isGroupGeneral => systemId == '${groupId}__general';
}

final class WalletPage<T> {
  WalletPage({required List<T> items, this.nextOffset})
    : items = List<T>.unmodifiable(items);

  final List<T> items;
  final int? nextOffset;
}

final class WalletCatalog {
  WalletCatalog({
    required List<WalletAccount> accounts,
    required List<WalletCategory> categories,
    List<WalletLabel>? labels,
  }) : accounts = List<WalletAccount>.unmodifiable(accounts),
       categories = List<WalletCategory>.unmodifiable(categories),
       labels = List<WalletLabel>.unmodifiable(labels ?? const []);

  final List<WalletAccount> accounts;
  final List<WalletCategory> categories;
  final List<WalletLabel> labels;
}

final class WalletLabel {
  const WalletLabel({required this.id, required this.name});

  final String id;
  final String name;
}

sealed class WalletReadResult {
  const WalletReadResult();
}

final class WalletReadSuccess extends WalletReadResult {
  const WalletReadSuccess(this.catalog);

  final WalletCatalog catalog;

  @override
  String toString() => 'WalletReadSuccess(${catalog.accounts.length} accounts)';
}

enum WalletReadFailureKind {
  invalidToken,
  initialSyncInProgress,
  rateLimited,
  offline,
  timeout,
  tls,
  service,
  protocol,
}

final class WalletReadFailure extends WalletReadResult {
  const WalletReadFailure._(this.kind, {this.retryAfterSeconds});

  const WalletReadFailure.invalidToken()
    : this._(WalletReadFailureKind.invalidToken);
  const WalletReadFailure.initialSyncInProgress()
    : this._(WalletReadFailureKind.initialSyncInProgress);
  const WalletReadFailure.rateLimited({int? retryAfterSeconds})
    : this._(
        WalletReadFailureKind.rateLimited,
        retryAfterSeconds: retryAfterSeconds,
      );
  const WalletReadFailure.offline() : this._(WalletReadFailureKind.offline);
  const WalletReadFailure.timeout() : this._(WalletReadFailureKind.timeout);
  const WalletReadFailure.tls() : this._(WalletReadFailureKind.tls);
  const WalletReadFailure.service() : this._(WalletReadFailureKind.service);
  const WalletReadFailure.protocol() : this._(WalletReadFailureKind.protocol);

  final WalletReadFailureKind kind;
  final int? retryAfterSeconds;

  String get userMessage => switch (kind) {
    WalletReadFailureKind.invalidToken =>
      'Wallet connection needs a valid token.',
    WalletReadFailureKind.initialSyncInProgress =>
      'Wallet connection is preparing its data.',
    WalletReadFailureKind.rateLimited =>
      'Wallet connection is rate limited. Try again later.',
    WalletReadFailureKind.offline => 'Wallet connection is offline.',
    WalletReadFailureKind.timeout => 'Wallet connection timed out.',
    WalletReadFailureKind.tls =>
      'Wallet connection could not verify its secure connection.',
    WalletReadFailureKind.service =>
      'Wallet connection is temporarily unavailable.',
    WalletReadFailureKind.protocol =>
      'Wallet connection returned an unsupported response.',
  };

  @override
  bool operator ==(Object other) =>
      other is WalletReadFailure &&
      other.kind == kind &&
      other.retryAfterSeconds == retryAfterSeconds;

  @override
  int get hashCode => Object.hash(kind, retryAfterSeconds);

  @override
  String toString() => 'WalletReadFailure(${kind.name})';
}

abstract interface class WalletCatalogCache {
  Future<WalletCatalog?> read();

  Future<void> write(WalletCatalog catalog);

  Future<void> clear();
}

abstract interface class WalletConnectionRepository {
  Future<WalletReadResult> refresh();
}
