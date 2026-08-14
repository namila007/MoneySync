import 'dart:collection';

import 'package:money_sync/core/errors/domain_failure.dart';

enum WalletMutationOperation { create, update, delete }

/// Role of one immutable item within a Wallet mutation batch
/// (plan/03 §wallet_mutation_item). Primary for ordinary records and
/// outside-Wallet transfers; a verified internal paired transfer carries a
/// source and a mirror leg.
enum WalletItemLegRole { primary, transferSource, transferMirror }

enum WalletMutationState {
  queued,
  syncing,
  reconciling,
  unknownDelivery,
  unknownUpdate,
  unknownDelete,
  retryScheduled,
  succeeded,
  permanentFailure,
  supersededBeforeSend,
}

extension WalletMutationStateTransitions on WalletMutationState {
  bool canTransitionTo(WalletMutationState next) => switch (this) {
    WalletMutationState.queued =>
      next == WalletMutationState.syncing ||
          next == WalletMutationState.supersededBeforeSend,
    WalletMutationState.syncing =>
      next == WalletMutationState.reconciling ||
          next == WalletMutationState.unknownDelivery ||
          next == WalletMutationState.unknownUpdate ||
          next == WalletMutationState.unknownDelete ||
          next == WalletMutationState.retryScheduled ||
          next == WalletMutationState.succeeded ||
          next == WalletMutationState.permanentFailure,
    WalletMutationState.reconciling =>
      next == WalletMutationState.succeeded ||
          next == WalletMutationState.retryScheduled ||
          next == WalletMutationState.permanentFailure,
    WalletMutationState.unknownDelivery ||
    WalletMutationState.unknownUpdate ||
    WalletMutationState.unknownDelete =>
      next == WalletMutationState.reconciling,
    WalletMutationState.retryScheduled => next == WalletMutationState.syncing,
    WalletMutationState.succeeded ||
    WalletMutationState.permanentFailure ||
    WalletMutationState.supersededBeforeSend => false,
  };
}

/// A single immutable remote-operation snapshot with a stable create lineage.
final class WalletMutationIntent {
  WalletMutationIntent({
    required this.id,
    required this.candidateId,
    required this.operation,
    required this.operationRevision,
    required this.lineageGeneration,
    required this.createLineageKey,
    required this.transactionFingerprint,
    required Map<String, Object?> payload,
    required this.state,
  }) : payload = UnmodifiableMapView<String, Object?>(_freezeMap(payload)) {
    if (id.isEmpty ||
        candidateId.isEmpty ||
        operationRevision < 1 ||
        lineageGeneration < 1 ||
        createLineageKey.isEmpty ||
        transactionFingerprint.isEmpty) {
      throw const InvalidMutationIntentFailure();
    }
  }

  final String id;
  final String candidateId;
  final WalletMutationOperation operation;
  final int operationRevision;
  final int lineageGeneration;
  final String createLineageKey;
  final String transactionFingerprint;
  final Map<String, Object?> payload;
  final WalletMutationState state;

  WalletMutationIntent transitionTo(WalletMutationState next) {
    if (!state.canTransitionTo(next)) {
      throw InvalidStateTransitionFailure(from: state.name, to: next.name);
    }
    return _copy(state: next);
  }

  WalletMutationIntent copyWith({
    String? candidateId,
    int? lineageGeneration,
    Map<String, Object?>? payload,
  }) {
    if ((candidateId != null && candidateId != this.candidateId) ||
        (lineageGeneration != null &&
            lineageGeneration != this.lineageGeneration)) {
      throw const InvalidMutationIntentFailure();
    }
    return _copy(payload: payload);
  }

  WalletMutationIntent _copy({
    WalletMutationState? state,
    Map<String, Object?>? payload,
  }) {
    return WalletMutationIntent(
      id: id,
      candidateId: candidateId,
      operation: operation,
      operationRevision: operationRevision,
      lineageGeneration: lineageGeneration,
      createLineageKey: createLineageKey,
      transactionFingerprint: transactionFingerprint,
      payload: payload ?? this.payload,
      state: state ?? this.state,
    );
  }

  static Map<String, Object?> _freezeMap(Map<String, Object?> value) =>
      Map<String, Object?>.unmodifiable(
        value.map((key, nested) => MapEntry(key, _freeze(nested))),
      );

  static Object? _freeze(Object? value) => switch (value) {
    Map<dynamic, dynamic> map => Map.unmodifiable(
      map.map((key, nested) => MapEntry(key, _freeze(nested))),
    ),
    List<dynamic> list => List.unmodifiable(list.map(_freeze)),
    _ => value,
  };
}
