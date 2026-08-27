import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

final log = Logger('mappings.editor');

/// Editor for one mapping rule. Serves `/mappings/new` (no [ruleId]) and
/// `/mappings/:id/edit`. Writes go through the versioned `SaveMappingRule`
/// use case — an existing rule is never updated in place (M5.3/M5.4).
class MappingEditorPage extends ConsumerStatefulWidget {
  const MappingEditorPage({super.key, this.ruleId});

  final String? ruleId;

  @override
  ConsumerState<MappingEditorPage> createState() => _MappingEditorPageState();
}

class _MappingEditorPageState extends ConsumerState<MappingEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _senderController = TextEditingController();
  final _instrumentController = TextEditingController();
  final _merchantController = TextEditingController();
  MappingSyncMode _syncMode = MappingSyncMode.review;
  String? _walletAccountId;
  String? _walletCategoryId;
  String _paymentType = 'debit_card';
  bool _enabled = true;
  bool _merchantExpanded = false;
  MerchantMatcherKind _merchantKind = MerchantMatcherKind.contains;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _senderController.dispose();
    _instrumentController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (widget.ruleId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final store = await ref.read(mappingRuleStoreProvider.future);
      final rule = await store.latest(widget.ruleId!);
      if (!mounted) return;
      if (rule == null) {
        setState(() => _loading = false);
        return;
      }
      _nameController.text = rule.name;
      _senderController.text = rule.senderMatcher.aliases.join(', ');
      _instrumentController.text = rule.instrumentSuffixHash ?? '';
      _merchantController.text = switch (rule.merchantMatcher) {
        ExactMerchantMatcher(merchant: final m) => m,
        ContainsMerchantMatcher(fragment: final f) => f,
        null => '',
      };
      _merchantKind = switch (rule.merchantMatcher) {
        ExactMerchantMatcher() => MerchantMatcherKind.exact,
        _ => MerchantMatcherKind.contains,
      };
      _merchantExpanded = rule.merchantMatcher != null;
      _syncMode = rule.syncMode;
      _walletAccountId = rule.walletAccountId;
      _walletCategoryId = rule.walletCategoryId;
      _paymentType = rule.paymentType;
      _enabled = rule.enabled;
      setState(() => _loading = false);
    } catch (e, st) {
      log.error('Failed to load mapping rule ${widget.ruleId}', e, st);
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load mapping rule.')),
        );
      }
    }
  }

  MappingRule? _buildDraft() {
    final aliases = _senderController.text
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();
    if (aliases.isEmpty || _walletAccountId == null) return null;
    final instrument = _instrumentController.text.trim();
    final merchantText = _merchantController.text.trim();

    return MappingRule(
      id: widget.ruleId ?? _randomId(),
      name: _nameController.text.trim().isEmpty
          ? aliases.first
          : _nameController.text.trim(),
      enabled: _enabled,
      senderMatcher: SenderMatcher(aliases),
      instrumentSuffixHash: instrument.isEmpty ? null : instrument,
      merchantMatcher: !_merchantExpanded || merchantText.isEmpty
          ? null
          : switch (_merchantKind) {
              MerchantMatcherKind.exact => ExactMerchantMatcher(merchantText),
              MerchantMatcherKind.contains => ContainsMerchantMatcher(
                merchantText,
              ),
            },
      walletAccountId: _walletAccountId!,
      walletCategoryId: _walletCategoryId,
      paymentType: _paymentType,
      syncMode: _syncMode,
      priority: 0,
      minConfidenceBasisPoints: null,
      ruleVersion: 1,
      createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final draft = _buildDraft();
    if (draft == null) return;
    setState(() => _saving = true);
    try {
      final useCase = await ref.read(saveMappingRuleProvider.future);
      await useCase.call(draft: draft, editingRuleId: widget.ruleId);
      log.info(
        'Saved mapping rule ${widget.ruleId ?? '(new)'} '
        'v${draft.ruleVersion}',
      );
      // Activity logging (Bug 8.3). Best-effort, never blocks UI.
      _logActivity(
        ActivityEventCode.mappingRuleCreated,
        message: 'Mapping rule saved',
      );
      if (!mounted) return;
      ref.invalidate(mappingRuleListProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mapping saved.')));
      Navigator.of(context).pop();
    } catch (e, s) {
      log.error('Failed to save mapping rule', e, s);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not save mapping.')));
    }
  }

  // ponytail: best-effort activity logging, never blocks UI on failure.
  void _logActivity(ActivityEventCode code, {String? message}) {
    try {
      final db = ref.read(appDatabaseProvider).asData?.value;
      if (db == null) return;
      db
          .select(db.appSettings)
          .getSingleOrNull()
          .then((setting) {
            db.insertActivity(
              activityType: code,
              safeDetailCode: ActivityStateTransition.logEvent,
              occurredAtEpochMs: DateTime.now().millisecondsSinceEpoch,
              privacyEpoch: setting?.privacyEpoch ?? 0,
              detailMessage: message,
            );
          })
          .catchError((_) {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isNew = widget.ruleId == null;

    return Scaffold(
      appBar: AppBar(title: Text(isNew ? 'New mapping' : 'Edit mapping')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Rule name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a rule name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _senderController,
              decoration: const InputDecoration(
                labelText: 'Sender (comma separated)',
                helperText: 'Exact normalized sender aliases',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter at least one sender'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instrumentController,
              decoration: const InputDecoration(
                labelText: 'Instrument suffix (optional)',
                helperText: 'Masked last digits, e.g. ••56',
              ),
            ),
            const SizedBox(height: 16),
            _WalletAccountPicker(
              selectedAccountId: _walletAccountId,
              selectedCategoryId: _walletCategoryId,
              paymentType: _paymentType,
              onAccountChanged: (id, categoryId) => setState(() {
                _walletAccountId = id;
                _walletCategoryId = categoryId;
              }),
              onPaymentTypeChanged: (v) => setState(() => _paymentType = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MappingSyncMode>(
              initialValue: _syncMode,
              decoration: const InputDecoration(labelText: 'Processing'),
              items: const [
                DropdownMenuItem(
                  value: MappingSyncMode.manual,
                  child: Text('Manual'),
                ),
                DropdownMenuItem(
                  value: MappingSyncMode.review,
                  child: Text('Review'),
                ),
                DropdownMenuItem(
                  value: MappingSyncMode.automatic,
                  child: Text('Automatic'),
                ),
              ],
              onChanged: (v) => setState(() => _syncMode = v ?? _syncMode),
            ),
            const SizedBox(height: 16),
            _MerchantMatcherSection(
              expanded: _merchantExpanded,
              kind: _merchantKind,
              controller: _merchantController,
              onToggle: (v) => setState(() => _merchantExpanded = v),
              onKindChanged: (v) => setState(() => _merchantKind = v),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
              title: const Text('Enabled'),
              subtitle: const Text('Disabled rules never match candidates'),
            ),
            if (_buildDraft() case final draft?) ...[
              const SizedBox(height: 8),
              RulePreviewPanel(resolver: MappingRuleResolver(rules: [draft])),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save mapping'),
            ),
          ],
        ),
      ),
    );
  }

  static String _randomId() =>
      'rule-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
}

/// Wallet target picker. Bank-synced/archived accounts stay visible but
/// disabled with an explanation (plan/04 mapping editor); foreign-currency
/// accounts are excluded for M5 (same-currency only).
class _WalletAccountPicker extends ConsumerWidget {
  const _WalletAccountPicker({
    required this.selectedAccountId,
    required this.selectedCategoryId,
    required this.paymentType,
    required this.onAccountChanged,
    required this.onPaymentTypeChanged,
  });

  final String? selectedAccountId;
  final String? selectedCategoryId;
  final String paymentType;
  final void Function(String accountId, String? categoryId) onAccountChanged;
  final ValueChanged<String> onPaymentTypeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(walletCatalogProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        catalogAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const Text('Wallet catalog unavailable.'),
          data: (catalog) {
            if (catalog == null || catalog.accounts.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Connect your Wallet to choose a target account.',
                  ),
                ),
              );
            }
            final lkrAccounts = catalog.accounts
                .where((a) => a.currencyCode.toUpperCase() == 'LKR')
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedAccountId,
                  decoration: const InputDecoration(
                    labelText: 'Wallet account',
                  ),
                  items: [
                    for (final account in lkrAccounts)
                      DropdownMenuItem(
                        value: account.id,
                        enabled:
                            account.eligibility ==
                            WalletAccountEligibility.eligible,
                        child: Text(
                          account.isBankSynced
                              ? '${account.name} (bank-synced)'
                              : account.name,
                        ),
                      ),
                  ],
                  onChanged: (id) {
                    if (id == null) return;
                    final account = lkrAccounts.firstWhere((a) => a.id == id);
                    if (account.eligibility !=
                        WalletAccountEligibility.eligible) {
                      return;
                    }
                    onAccountChanged(id, null);
                  },
                  validator: (v) =>
                      v == null ? 'Choose a Wallet account' : null,
                ),
                if (lkrAccounts.any(
                  (a) => a.eligibility != WalletAccountEligibility.eligible,
                ))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _disabledAccountsHint(lkrAccounts),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: paymentType,
                  decoration: const InputDecoration(labelText: 'Payment type'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(
                      value: 'debit_card',
                      child: Text('Debit card'),
                    ),
                    DropdownMenuItem(
                      value: 'credit_card',
                      child: Text('Credit card'),
                    ),
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text('Transfer'),
                    ),
                  ],
                  onChanged: (v) => onPaymentTypeChanged(v ?? 'debit_card'),
                ),
              ],
            );
          },
        ),
        if (selectedCategoryId != null)
          Text(
            'Category: $selectedCategoryId',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  static String _disabledAccountsHint(List<WalletAccount> accounts) {
    final reasons = accounts
        .where((a) => a.eligibility != WalletAccountEligibility.eligible)
        .map(
          (a) => switch (a.eligibility) {
            WalletAccountEligibility.bankSynced =>
              '${a.name} is bank-synced (not writable)',
            WalletAccountEligibility.archived => '${a.name} is archived',
            WalletAccountEligibility.unwritable =>
              '${a.name} is not yet writable',
            WalletAccountEligibility.missingRequiredFields =>
              '${a.name} requires a currency or name from Wallet',
            WalletAccountEligibility.foreignCurrencyReviewOnly =>
              '${a.name} uses a different currency (review only)',
            WalletAccountEligibility.eligible => '',
          },
        );
    return reasons.where((r) => r.isNotEmpty).join('. ');
  }
}

class _MerchantMatcherSection extends StatelessWidget {
  const _MerchantMatcherSection({
    required this.expanded,
    required this.kind,
    required this.controller,
    required this.onToggle,
    required this.onKindChanged,
  });

  final bool expanded;
  final MerchantMatcherKind kind;
  final TextEditingController controller;
  final ValueChanged<bool> onToggle;
  final ValueChanged<MerchantMatcherKind> onKindChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Merchant matcher'),
          subtitle: const Text('Optional exact or contains match (no regex)'),
          trailing: Switch(value: expanded, onChanged: onToggle),
        ),
        if (expanded) ...[
          SegmentedButton<MerchantMatcherKind>(
            segments: const [
              ButtonSegment(
                value: MerchantMatcherKind.exact,
                label: Text('Exact'),
              ),
              ButtonSegment(
                value: MerchantMatcherKind.contains,
                label: Text('Contains'),
              ),
            ],
            selected: {kind},
            onSelectionChanged: (s) => onKindChanged(s.first),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Merchant'),
          ),
        ],
      ],
    );
  }
}

enum MerchantMatcherKind { exact, contains }

/// Redacted, read-only preview panel: runs a small local sample of redacted
/// candidates through [resolver] to show which rule would match. Purely a
/// preview surface — performs no writes (M5.4).
class RulePreviewPanel extends StatelessWidget {
  const RulePreviewPanel({super.key, required this.resolver});

  final MappingRuleResolver resolver;

  static const _samples = <MappingResolutionInput>[
    MappingResolutionInput(
      senderNormalized: 'BANK ALPHA',
      confidenceBasisPoints: 9500,
      merchantNormalized: 'REDACTED MERCHANT',
      instrumentSuffixHash: '••56',
      direction: TransactionDirection.debit,
    ),
    MappingResolutionInput(
      senderNormalized: 'BANK BETA',
      confidenceBasisPoints: 8800,
      merchantNormalized: 'REDACTED MERCHANT',
      direction: TransactionDirection.credit,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final rows = _samples.map((sample) {
      final resolution = resolver.resolve(sample);
      final label = switch (resolution) {
        MappingResolved(:final rule) => 'Match → ${rule.name}',
        MappingAmbiguous() => 'Ambiguous — review',
        MappingUnmatched() => 'No match',
      };
      return ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(
          '${sample.senderNormalized} · ${sample.instrumentSuffixHash ?? 'no instrument'}',
        ),
        trailing: Text(label),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview (sample candidates)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            ...rows,
          ],
        ),
      ),
    );
  }
}
