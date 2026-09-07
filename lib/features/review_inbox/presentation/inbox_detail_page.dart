import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_page.dart'
    show StatusChip;
import 'package:money_sync/features/review_inbox/presentation/review_transaction_panel.dart';

final class CandidateSummaryView {
  const CandidateSummaryView({
    required this.kind,
    required this.direction,
    required this.lifecycle,
    required this.amountMinor,
    required this.amountCurrency,
    required this.confidenceBasisPoints,
    required this.requiresReview,
    this.transactionAtUtc,
    this.counterParty,
  });

  final String kind;
  final String direction;
  final String lifecycle;
  final int amountMinor;
  final String amountCurrency;
  final int confidenceBasisPoints;
  final bool requiresReview;
  final DateTime? transactionAtUtc;
  final String? counterParty;

  static CandidateSummaryView? parse(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;
      final amountMinor = decoded['amountMinor'];
      final confidence = decoded['confidenceBasisPoints'];
      final requiresReview = decoded['requiresReview'];
      if (amountMinor is! int ||
          confidence is! int ||
          requiresReview is! bool) {
        return null;
      }
      return CandidateSummaryView(
        kind: decoded['kind'] as String? ?? 'unknown',
        direction: decoded['direction'] as String? ?? 'neutral',
        lifecycle: decoded['lifecycle'] as String? ?? 'unclassified',
        amountMinor: amountMinor,
        amountCurrency: decoded['amountCurrency'] as String? ?? 'LKR',
        confidenceBasisPoints: confidence,
        requiresReview: requiresReview,
        transactionAtUtc: _parseDateTime(decoded['transactionAtUtc']),
        counterParty: decoded['counterParty'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value).toUtc();
      } catch (_) {}
    }
    return null;
  }
}

final class InboxDetailData {
  const InboxDetailData({this.event, this.summary, this.candidatePayload});

  final SmsEvent? event;
  final CandidateSummaryView? summary;
  final String? candidatePayload;
}

final inboxDetailProvider = FutureProvider.autoDispose
    .family<InboxDetailData, int>((ref, id) async {
      final db = await ref.watch(appDatabaseProvider.future);
      final event = await db.getSmsEventById(id);
      if (event == null) return const InboxDetailData();
      final candidate = await db.getCandidateBySmsEventId(event.id);
      final summary = candidate == null
          ? null
          : CandidateSummaryView.parse(candidate.encryptedPayload);
      return InboxDetailData(
        event: event,
        summary: summary,
        candidatePayload: candidate?.encryptedPayload,
      );
    });

class InboxDetailPage extends ConsumerWidget {
  const InboxDetailPage({super.key, required this.smsEventId});

  final int smsEventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(inboxDetailProvider(smsEventId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox Detail'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load message: $e')),
        data: (detail) {
          final event = detail.event;
          if (event == null) {
            return const Center(child: Text('Message not found.'));
          }
          final senderName = event.senderDisplay ?? event.senderKey;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              // Sender name
              Text(senderName.toUpperCase(), style: AppTypography.h3),
              const SizedBox(height: 4),
              Text(
                'Key: ${event.senderKey} \u00b7 ${_formatTime(event.receivedAtEpochMs)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),

              // Message body
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: AppColors.surface),
                child: Text(
                  event.encryptedBody ?? event.redactedBody ?? '(no body)',
                  style: AppTypography.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),

              // Status
              Row(
                children: [
                  Text(
                    'Status: ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  StatusChip(status: event.status),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),

              // Amount card
              if (detail.summary case final summary?)
                _AmountCard(summary: summary),

              const SizedBox(height: AppSpacing.s6),

              // REVIEW TRANSACTION
              Text('REVIEW TRANSACTION', style: AppTypography.h6),
              const SizedBox(height: AppSpacing.s4),

              ReviewTransactionPanel(
                smsEventId: event.id,
                encryptedPayload: detail.candidatePayload ?? '{}',
                senderNormalized: event.senderKey,
                initialSummary: detail.summary,
                fallbackDate: DateTime.fromMillisecondsSinceEpoch(
                  event.receivedAtEpochMs,
                  isUtc: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.summary});

  final CandidateSummaryView summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatAmount(summary.amountMinor, summary.amountCurrency),
                  style: AppTypography.amount,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent100,
                  border: Border.all(color: AppColors.accent, width: 1),
                ),
                child: Text(
                  _confidenceLabel(summary.confidenceBasisPoints),
                  style: AppTypography.micro.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Requires review: ${summary.requiresReview ? 'Yes' : 'No'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showDetailSheet(context),
                child: Text(
                  'Detail',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(int minorUnits, String code) {
    final sign = minorUnits < 0 ? '-' : '';
    final majorUnits = minorUnits.abs() / 100;
    final formatted = majorUnits
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$sign$code $formatted';
  }

  String _confidenceLabel(int basisPoints) {
    final pct = basisPoints ~/ 100;
    if (pct >= 80) return 'High Confidence';
    if (pct >= 50) return 'Medium Confidence';
    return 'Low Confidence';
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text('Candidate detail', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.s4),
            for (final (label, value) in [
              (
                'Amount',
                _formatAmount(summary.amountMinor, summary.amountCurrency),
              ),
              ('Kind', summary.kind),
              ('Direction', summary.direction),
              (
                'Date',
                summary.transactionAtUtc != null
                    ? '${summary.transactionAtUtc!.year}-${summary.transactionAtUtc!.month.toString().padLeft(2, '0')}-${summary.transactionAtUtc!.day.toString().padLeft(2, '0')}'
                    : 'Unknown',
              ),
              ('Confidence', _confidenceLabel(summary.confidenceBasisPoints)),
              ('Category', summary.lifecycle),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: AppTypography.body.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    Text(
                      value,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.s4),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
