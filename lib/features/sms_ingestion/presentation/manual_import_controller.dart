import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/features/sms_ingestion/data/share_intent_pigeon.g.dart';
import 'package:money_sync/features/sms_ingestion/domain/ingest_manual_message.dart';
import 'package:money_sync/features/sms_ingestion/domain/manual_input_validation.dart';

import 'share_intent_controller.dart';

enum ManualImportStep { input, preview, result }

final class ManualImportState {
  const ManualImportState({
    this.body = '',
    this.sender = '',
    this.step = ManualImportStep.input,
    this.isShareIntent = false,
    this.isSubmitting = false,
    this.resultMessage,
    this.resultType,
  });

  factory ManualImportState.initial() => const ManualImportState();

  factory ManualImportState.shareReceived(SharedTextPayload payload) =>
      ManualImportState(
        body: payload.text,
        step: ManualImportStep.input,
        isShareIntent: true,
      );

  final String body;
  final String sender;
  final ManualImportStep step;
  final bool isShareIntent;
  final bool isSubmitting;
  final String? resultMessage;
  final ImportResultType? resultType;

  int get bodyLength => body.length;
  bool get canSubmit =>
      bodyLength >= kMinBodyLength && bodyLength <= kMaxBodyLength;

  ManualImportState copyWith({
    String? body,
    String? sender,
    ManualImportStep? step,
    bool? isShareIntent,
    bool? isSubmitting,
    String? resultMessage,
    ImportResultType? resultType,
  }) {
    return ManualImportState(
      body: body ?? this.body,
      sender: sender ?? this.sender,
      step: step ?? this.step,
      isShareIntent: isShareIntent ?? this.isShareIntent,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      resultMessage: resultMessage ?? this.resultMessage,
      resultType: resultType ?? this.resultType,
    );
  }
}

enum ImportResultType { success, alreadyPresent, filtered, rejected, error }

class ManualImportController extends Notifier<ManualImportState> {
  // ponytail: in-memory sliding window; resets on process death — fine for
  // the anti-spam rate limit. Move to Drift if it must survive restarts.
  static const _rateWindow = Duration(minutes: 1);
  static const _maxImportsPerWindow = 20;

  final List<int> _recentIngestEpochMs = [];

  @override
  ManualImportState build() {
    ref.listen(shareIntentProvider, (_, next) {
      if (next != null) {
        state = ManualImportState.shareReceived(next);
      }
    });
    return ManualImportState.initial();
  }

  void updateBody(String value) => state = state.copyWith(body: value);
  void updateSender(String value) => state = state.copyWith(sender: value);

  bool get _isRateLimited {
    final now = DateTime.now().millisecondsSinceEpoch;
    _recentIngestEpochMs.removeWhere(
      (t) => now - t > _rateWindow.inMilliseconds,
    );
    return _recentIngestEpochMs.length >= _maxImportsPerWindow;
  }

  void submit() {
    final body = state.body;
    final result = validateManualInput(
      body,
      rawSender: state.sender,
      mimeType: 'text/plain',
    );
    if (result is ManualInputRejected) {
      state = state.copyWith(
        step: ManualImportStep.result,
        resultMessage: _rejectionMessage(result.reason),
        resultType: ImportResultType.rejected,
      );
      return;
    }
    state = state.copyWith(step: ManualImportStep.preview);
  }

  void backToInput() => state = state.copyWith(step: ManualImportStep.input);

  Future<void> confirm() async {
    if (_isRateLimited) {
      state = state.copyWith(
        step: ManualImportStep.result,
        resultMessage: _rejectionMessage(ManualInputRejection.rateLimited),
        resultType: ImportResultType.rejected,
      );
      return;
    }

    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) {
      state = state.copyWith(
        step: ManualImportStep.result,
        resultMessage: 'Service unavailable',
        resultType: ImportResultType.error,
      );
      return;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final setting = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      final body = state.body;
      final sender = state.sender;
      final isShareIntent = state.isShareIntent;
      final ingest = IngestManualMessage(
        database: db,
        identitySigner: ref.read(sourceIdentitySignerProvider),
      );
      final outcome = await ingest(
        rawBody: body,
        rawSender: sender,
        source: isShareIntent
            ? IngestionSource.shareIntent
            : IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: setting.privacyEpoch,
      );
      _recentIngestEpochMs.add(DateTime.now().millisecondsSinceEpoch);

      switch (outcome) {
        case ManualIngestStored(:final duplicateSuspected):
          state = state.copyWith(
            step: ManualImportStep.result,
            isSubmitting: false,
            resultMessage: duplicateSuspected
                ? 'Message imported, but it looks like a message you '
                      'already imported.'
                : 'Message imported and queued for review.',
            resultType: ImportResultType.success,
          );
        case ManualIngestAlreadyPresent():
          state = state.copyWith(
            step: ManualImportStep.result,
            isSubmitting: false,
            resultMessage: 'This message was already imported.',
            resultType: ImportResultType.alreadyPresent,
          );
        case ManualIngestFiltered(:final triage):
          state = state.copyWith(
            step: ManualImportStep.result,
            isSubmitting: false,
            resultMessage: 'Message filtered: ${triage.name}.',
            resultType: ImportResultType.filtered,
          );
        case ManualIngestRejected(:final reason):
          state = state.copyWith(
            step: ManualImportStep.result,
            isSubmitting: false,
            resultMessage: _rejectionMessage(reason),
            resultType: ImportResultType.rejected,
          );
        case ManualIngestBlockedByEpoch():
          state = state.copyWith(
            step: ManualImportStep.result,
            isSubmitting: false,
            resultMessage: 'Operation blocked by privacy policy.',
            resultType: ImportResultType.error,
          );
      }
    } catch (e) {
      state = state.copyWith(
        step: ManualImportStep.result,
        isSubmitting: false,
        resultMessage: 'Error: $e',
        resultType: ImportResultType.error,
      );
    }
  }

  void discard() {
    state = ManualImportState.initial();
    ref.read(shareIntentProvider.notifier).clear();
  }

  void tryAgain() => state = state.copyWith(
    step: ManualImportStep.input,
    resultMessage: null,
    resultType: null,
  );

  static String _rejectionMessage(ManualInputRejection reason) {
    return switch (reason) {
      ManualInputRejection.empty => 'Message body is empty.',
      ManualInputRejection.tooShort =>
        'Message is too short (minimum 12 characters).',
      ManualInputRejection.tooLong =>
        'Message is too long (maximum 2000 characters).',
      ManualInputRejection.unsupportedMimeType => 'Unsupported file type.',
      ManualInputRejection.controlCharacters => 'Invalid characters detected.',
      ManualInputRejection.senderTooLong =>
        'Sender name is too long (max 32 characters).',
      ManualInputRejection.rateLimited => 'Too many imports. Please wait.',
      ManualInputRejection.notPlausiblyFinancial =>
        'Does not appear to be a financial message.',
    };
  }
}

final manualImportProvider =
    NotifierProvider<ManualImportController, ManualImportState>(
      ManualImportController.new,
    );
