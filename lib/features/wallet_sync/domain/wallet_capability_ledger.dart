enum WalletRemoteCapability { create, reconciliation, patch, delete, transfer }

enum WalletCapabilityOutcome { pass, fail, unknown }

final class WalletCapabilityEvidence {
  WalletCapabilityEvidence({
    required this.capability,
    required this.outcome,
    required this.observedAt,
    required this.contractVersion,
  }) {
    if (contractVersion.isEmpty) {
      throw ArgumentError.value(
        contractVersion,
        'contractVersion',
        'must not be empty',
      );
    }
  }

  final WalletRemoteCapability capability;
  final WalletCapabilityOutcome outcome;
  final DateTime observedAt;
  final String contractVersion;
}

final class WalletCapabilityLedger {
  WalletCapabilityLedger({required List<WalletCapabilityEvidence> evidence})
    : evidence = List<WalletCapabilityEvidence>.unmodifiable(evidence);

  final List<WalletCapabilityEvidence> evidence;

  bool canCreate({
    required DateTime now,
    required String compatibleContractVersion,
  }) =>
      _isPassing(
        WalletRemoteCapability.create,
        now,
        compatibleContractVersion,
      ) &&
      _isPassing(
        WalletRemoteCapability.reconciliation,
        now,
        compatibleContractVersion,
      );

  bool _isPassing(
    WalletRemoteCapability capability,
    DateTime now,
    String contractVersion,
  ) {
    final compatible =
        evidence
            .where(
              (entry) =>
                  entry.capability == capability &&
                  entry.contractVersion == contractVersion &&
                  !entry.observedAt.isAfter(now) &&
                  now.difference(entry.observedAt) <= const Duration(days: 30),
            )
            .toList()
          ..sort((a, b) => b.observedAt.compareTo(a.observedAt));
    return compatible.isNotEmpty &&
        compatible.first.outcome == WalletCapabilityOutcome.pass;
  }
}
