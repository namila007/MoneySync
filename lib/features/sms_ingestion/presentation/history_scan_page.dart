import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/features/sms_ingestion/presentation/history_import_controller.dart';

class HistoryImportPage extends ConsumerStatefulWidget {
  const HistoryImportPage({super.key});

  @override
  ConsumerState<HistoryImportPage> createState() => _HistoryImportPageState();
}

class _HistoryImportPageState extends ConsumerState<HistoryImportPage> {
  bool _showCustomCap = false;
  final _customCapController = TextEditingController();

  Future<void> _pickCustomDateRange(
    BuildContext context,
    HistoryImportController controller,
  ) async {
    final now = DateTime.now();
    final from = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.accent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (from == null || !context.mounted) return;
    final to = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: from,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.accent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (to == null) return;
    controller.setCustomDateRange(from, to);
  }

  String _formatDateShort(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  void dispose() {
    _customCapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyImportProvider);
    final controller = ref.read(historyImportProvider.notifier);

    if (state.terminalResult != null) {
      return _ResultView(state: state, controller: controller);
    }

    final hasTracked = state.trackedSenders.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History Import'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // "Data Recovery" tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: const BoxDecoration(color: AppColors.accent100),
            child: Text(
              'Data Recovery',
              style: AppTypography.micro.copyWith(color: AppColors.accent800),
            ),
          ),
          const SizedBox(height: 12),

          // Title + subtitle
          Text('Sync Past Activity', style: AppTypography.display),
          const SizedBox(height: 4),
          Text(
            'Import your historical SMS alerts to build a complete '
            'financial picture from the last few months.',
            style: AppTypography.body.copyWith(
              color: AppColors.text.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: AppSpacing.s6),

          // 1. Choose Sources
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1. CHOOSE SOURCES', style: AppTypography.h6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: const BoxDecoration(color: AppColors.neutral100),
                child: Text(
                  '${state.trackedSenders.length} available',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.neutral800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Source cards (horizontal scroll)
          if (state.trackedSenders.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.trackedSenders.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final sender = state.trackedSenders[index];
                  return Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(color: AppColors.text),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sender.toUpperCase(),
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.bg,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${100 + index * 200} msgs',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.bg.withValues(alpha: 0.75),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppColors.surface),
              child: Text(
                'No senders tracked. Add senders first.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Update sources button
          OutlinedButton(
            onPressed: () => context
                .push('/settings/tracked-senders')
                .then((_) => controller.reloadTrackedSenders()),
            child: const Text('Update sources'),
          ),
          const SizedBox(height: AppSpacing.s6),

          // Divider
          Container(
            height: 2,
            color: AppColors.divider(Theme.of(context).brightness),
          ),
          const SizedBox(height: AppSpacing.s6),

          // 2. Configuration
          Text('2. CONFIGURATION', style: AppTypography.h6),
          const SizedBox(height: 10),

          // Import range selector — preset buttons + custom date range
          Text(
            'IMPORT RANGE',
            style: AppTypography.micro.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final days in [7, 14, 30, 60])
                GestureDetector(
                  onTap: () => controller.selectPreset(days),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: state.windowDays == days && state.fromDate == null
                          ? AppColors.text
                          : AppColors.surface,
                      border: Border.all(
                        color: state.windowDays == days && state.fromDate == null
                            ? AppColors.text
                            : AppColors.divider(Theme.of(context).brightness),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '$days days',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: state.windowDays == days && state.fromDate == null
                            ? AppColors.bg
                            : AppColors.text,
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => _pickCustomDateRange(context, controller),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: state.fromDate != null
                        ? AppColors.accent
                        : AppColors.surface,
                    border: Border.all(
                      color: state.fromDate != null
                          ? AppColors.accent
                          : AppColors.divider(Theme.of(context).brightness),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    state.fromDate != null
                        ? '${_formatDateShort(state.fromDate!)} – ${_formatDateShort(state.toDate!)}'
                        : 'Custom range',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: state.fromDate != null ? Colors.white : AppColors.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),

          // Scan depth — preset buttons + custom
          Text(
            'SCAN DEPTH',
            style: AppTypography.micro.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cap in [5, 20, 50])
                GestureDetector(
                  onTap: () {
                    controller.setMessageCap(cap);
                    setState(() => _showCustomCap = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: state.messageCap == cap && !_showCustomCap
                          ? AppColors.accent
                          : AppColors.surface,
                      border: Border.all(
                        color: state.messageCap == cap && !_showCustomCap
                            ? AppColors.accent
                            : AppColors.divider(Theme.of(context).brightness),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '$cap',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: state.messageCap == cap && !_showCustomCap
                            ? Colors.white
                            : AppColors.text,
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => setState(() => _showCustomCap = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _showCustomCap
                        ? AppColors.accent
                        : AppColors.surface,
                    border: Border.all(
                      color: _showCustomCap
                          ? AppColors.accent
                          : AppColors.divider(Theme.of(context).brightness),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Custom',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _showCustomCap ? Colors.white : AppColors.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showCustomCap) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: 160,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _customCapController,
                style: AppTypography.bodySmall,
                decoration: InputDecoration(
                  hintText: 'Messages',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral400,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                      color: AppColors.divider(Theme.of(context).brightness),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                      color: AppColors.divider(Theme.of(context).brightness),
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check, size: 18),
                    onPressed: () {
                      final val = int.tryParse(_customCapController.text);
                      if (val != null && val >= 1) {
                        controller.setMessageCap(val);
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  final val = int.tryParse(value);
                  if (val != null && val >= 1) {
                    controller.setMessageCap(val);
                  }
                },
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            'Maximum messages to scan per source',
            style: AppTypography.bodyXs.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.s6),

          // Privacy Guard card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.surface),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Guard Active',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'MoneySync processes all SMS data locally on your '
                        'device. No private message content ever leaves '
                        'your phone.',
                        style: AppTypography.bodyXs.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (state.isScanning) ...[
            const SizedBox(height: AppSpacing.s4),
            const Center(child: CircularProgressIndicator()),
          ] else ...[
            const SizedBox(height: AppSpacing.s6),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: hasTracked ? () => controller.startImport() : null,
                child: const Text('Initiate bulk import'),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'estimated time: ${state.windowDays * 2} seconds',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultView extends StatefulWidget {
  const _ResultView({required this.state, required this.controller});

  final HistoryImportState state;
  final HistoryImportController controller;

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  bool _showSkipExplanation = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = widget.controller;
    final t = state.terminalResult;
    final isSuccess = t == TerminalResult.completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History Import'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.info_outline,
                size: 48,
                color: isSuccess ? AppColors.accent : AppColors.neutral600,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                isSuccess ? 'Import finished' : 'Import done',
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                '${state.imported} stored · '
                '${state.filtered} not recognised · '
                '${state.duplicates} already imported',
                textAlign: TextAlign.center,
              ),
              if (state.filtered > 0) ...[
                const SizedBox(height: AppSpacing.s2),
                TextButton(
                  onPressed: () => setState(
                    () => _showSkipExplanation = !_showSkipExplanation,
                  ),
                  child: const Text('Why were some messages skipped?'),
                ),
                if (_showSkipExplanation)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s2,
                    ),
                    child: Text(
                      'One-time passwords, promotions, and messages that do '
                      'not look like a bank transaction are never stored.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall,
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.s8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    controller.reset();
                    context.go('/');
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
