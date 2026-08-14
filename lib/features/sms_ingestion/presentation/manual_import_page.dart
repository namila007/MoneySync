import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/sms_ingestion/presentation/manual_import_controller.dart';

const _kMaxBodyLength = 2000;

class ManualImportPage extends ConsumerStatefulWidget {
  const ManualImportPage({super.key});

  @override
  ConsumerState<ManualImportPage> createState() => _ManualImportPageState();
}

class _ManualImportPageState extends ConsumerState<ManualImportPage> {
  final _bodyController = TextEditingController();
  final _senderController = TextEditingController();
  final _bodyFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bodyFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _senderController.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manualImportProvider);
    final controller = ref.read(manualImportProvider.notifier);

    if (state.step == ManualImportStep.result) {
      return _ResultView(state: state, controller: controller);
    }
    if (state.step == ManualImportStep.preview) {
      return _PreviewView(state: state, controller: controller);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Paste a message')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.isShareIntent)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Shared messages always go to review.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (state.isShareIntent) const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              focusNode: _bodyFocus,
              maxLines: 8,
              maxLength: _kMaxBodyLength,
              decoration: const InputDecoration(
                labelText: 'Paste bank message here',
                hintText:
                    'e.g. Your bank card xx1234 was '
                    'debited 1,500.00 at a store...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (value) => controller.updateBody(value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _senderController,
              decoration: const InputDecoration(
                labelText: 'Sender (optional)',
                hintText: 'e.g. BANKNAME',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: (value) => controller.updateSender(value),
            ),
            const SizedBox(height: 12),
            Text(
              '${state.bodyLength} / $_kMaxBodyLength',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: state.bodyLength > _kMaxBodyLength
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: state.canSubmit && !state.isSubmitting
                  ? controller.submit
                  : null,
              icon: const Icon(Icons.check),
              label: const Text('Review'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({required this.state, required this.controller});

  final ManualImportState state;
  final ManualImportController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review message'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.backToInput,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sender',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      state.sender.isEmpty ? 'Not specified' : state.sender,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Divider(height: 24),
                    Text(
                      'Message',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.body.isEmpty ? '(empty)' : state.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (state.isShareIntent)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Shared messages are permanently review-only.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            if (state.isSubmitting)
              const Center(child: CircularProgressIndicator()),
            if (!state.isSubmitting) ...[
              FilledButton.icon(
                onPressed: () => controller.confirm(),
                icon: const Icon(Icons.add),
                label: const Text('Add message'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => controller.discard(),
                child: const Text('Discard'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.state, required this.controller});

  final ManualImportState state;
  final ManualImportController controller;

  @override
  Widget build(BuildContext context) {
    final isSuccess = switch (state.resultType) {
      null => false,
      ImportResultType.success => true,
      ImportResultType.alreadyPresent => true,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.info_outline,
                size: 64,
                color: isSuccess
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                state.resultMessage ?? 'Unknown result.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => controller.discard(),
                child: const Text('Done'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => controller.tryAgain(),
                child: const Text('Import another'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
