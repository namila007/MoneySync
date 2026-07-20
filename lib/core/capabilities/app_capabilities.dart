enum AppCapability {
  walletCreate,
  walletPatch,
  walletDelete,
  historySms,
  liveSms,
  mlKitEntities,
  localLearning,
  internalTransfer,
  outsideTransfer,
  automaticSync,
  settingsExport,
  modelTransfer,
}

/// A capability registry that defaults to disabled until a milestone supplies
/// validated native and application evidence for an explicit activation.
final class AppCapabilities {
  const AppCapabilities.m0();

  bool isEnabled(AppCapability capability) => false;

  String explanationFor(AppCapability capability) => switch (capability) {
    AppCapability.walletCreate =>
      'Wallet creation remains disabled until the Wallet contract spike passes.',
    AppCapability.walletPatch =>
      'Wallet updates remain disabled until ownership and PATCH behavior are verified.',
    AppCapability.walletDelete =>
      'Wallet deletion remains disabled until ownership and DELETE behavior are verified.',
    AppCapability.historySms =>
      'SMS history access is disabled until its privacy and durability gates pass.',
    AppCapability.liveSms =>
      'Live SMS capture is disabled until its permission and durability gates pass.',
    AppCapability.mlKitEntities =>
      'ML-assisted extraction is disabled until the ML Kit spike passes.',
    AppCapability.localLearning =>
      'Local learning is disabled until encrypted data foundations are available.',
    AppCapability.internalTransfer =>
      'Internal transfers remain review-only until their Wallet contract is verified.',
    AppCapability.outsideTransfer =>
      'Outside transfers remain review-only until their Wallet contract is verified.',
    AppCapability.automaticSync =>
      'Automatic sync is disabled until every safety and reconciliation gate passes.',
    AppCapability.settingsExport =>
      'Settings export is disabled until scoped document and encryption gates pass.',
    AppCapability.modelTransfer =>
      'Model transfer is disabled until encrypted bundle validation is available.',
  };
}
