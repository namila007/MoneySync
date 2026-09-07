import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/features/sms_ingestion/data/sms_history_pigeon.g.dart';
import 'package:money_sync/features/sms_tracking/presentation/tracked_senders_controller.dart';

class TrackedSendersPage extends ConsumerStatefulWidget {
  const TrackedSendersPage({super.key, this.loadDeviceSenders});

  final Future<List<String>> Function()? loadDeviceSenders;

  @override
  ConsumerState<TrackedSendersPage> createState() => _TrackedSendersPageState();
}

class _TrackedSendersPageState extends ConsumerState<TrackedSendersPage> {
  List<String> _deviceSenders = const [];
  bool _loadingSenders = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDeviceSenders());
  }

  Future<void> _loadDeviceSenders() async {
    setState(() => _loadingSenders = true);
    try {
      final loader =
          widget.loadDeviceSenders ??
          () async => (await SmsHistoryHostApi().distinctSenders())
              .whereType<String>()
              .toList();
      final senders = await loader();
      if (mounted) {
        setState(() {
          _deviceSenders = senders;
          _loadingSenders = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSenders = false);
    }
  }

  Future<void> _saveAndPop() async {
    final notifier = ref.read(trackedSendersControllerProvider.notifier);
    await notifier.save();
    if (mounted) Navigator.of(context).pop();
  }

  void _trackAll(List<String> candidates) {
    final notifier = ref.read(trackedSendersControllerProvider.notifier);
    for (final sender in candidates) {
      final tracked = ref.read(trackedSendersControllerProvider).value ?? [];
      if (!tracked.contains(sender)) {
        notifier.toggle(sender);
      }
    }
  }

  void _deselectAll() {
    final notifier = ref.read(trackedSendersControllerProvider.notifier);
    final tracked = ref.read(trackedSendersControllerProvider).value ?? [];
    for (final sender in tracked) {
      notifier.toggle(sender);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackedAsync = ref.watch(trackedSendersControllerProvider);
    final tracked = trackedAsync.value ?? const <String>[];

    final candidates = <String>[
      ..._deviceSenders,
      ...tracked.where((a) => !_deviceSenders.contains(a)),
    ];
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? candidates
        : candidates.where((s) => s.toLowerCase().contains(query)).toList();

    final activeCount = tracked.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracked Senders'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.save_outlined, color: AppColors.accent),
            onPressed: _saveAndPop,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              children: [
                // Description
                Text(
                  'Only messages from senders you choose are ever read.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),

                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or keyword...',
                    hintStyle: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral400,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 18),
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
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.s4),

                // Synchronization Logic card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: AppColors.surface),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Synchronization Logic', style: AppTypography.h5),
                      const SizedBox(height: 6),
                      Text(
                        'MoneySync only scans messages from the senders selected '
                        'below.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),

                // Available Sources header
                if (_loadingSenders)
                  const LinearProgressIndicator()
                else if (candidates.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: AppColors.surface),
                    child: Text(
                      'No senders found. Senders appear here after they are detected in your SMS inbox.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AVAILABLE SOURCES (${filtered.length})',
                        style: AppTypography.h6,
                      ),
                      Text(
                        '$activeCount active',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Sender cards
                  for (final sender in filtered)
                    _SenderCard(
                      sender: sender,
                      isSelected: tracked.contains(sender),
                      onTap: () => ref
                          .read(trackedSendersControllerProvider.notifier)
                          .toggle(sender),
                    ),
                ],
                const SizedBox(height: AppSpacing.s4),
              ],
            ),
          ),

          // Bottom buttons
          if (!_loadingSenders && candidates.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.divider(Theme.of(context).brightness),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _trackAll(candidates),
                      child: const Text('Track all'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _deselectAll,
                      child: const Text('Deselect all'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SenderCard extends StatelessWidget {
  const _SenderCard({
    required this.sender,
    required this.isSelected,
    required this.onTap,
  });

  final String sender;
  final bool isSelected;
  final VoidCallback onTap;

  String get _initials {
    final words = sender.split(RegExp(r'[\s_\-]+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    final clean = sender.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (clean.length >= 2) {
      return clean.substring(0, 2).toUpperCase();
    }
    return sender.substring(0, sender.length.clamp(0, 2)).toUpperCase();
  }

  String get _senderType {
    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    final type = _senderType;
    final isBank = type == 'Bank';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent100 : AppColors.surface,
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider(Theme.of(context).brightness),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar with initials
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.neutral200),
              child: Text(
                _initials,
                style: AppTypography.label.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + type tag + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        sender.toUpperCase(),
                        style: AppTypography.h5.copyWith(fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isBank
                              ? AppColors.accent100
                              : AppColors.accent100,
                          border: Border.all(color: AppColors.accent, width: 1),
                        ),
                        child: Text(
                          type,
                          style: AppTypography.micro.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _descriptionForSender(sender),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.neutral400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _descriptionForSender(String sender) {
    return 'Transaction notifications';
  }
}
