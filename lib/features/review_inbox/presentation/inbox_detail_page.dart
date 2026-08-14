import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_page.dart'
    show StatusChip;

/// Read-only summary of one stored candidate (M4.15 WP1). The candidate
/// table's rich columns are not populated yet — the parser payload JSON is
/// the display source. Parse failures degrade to "no summary", never crash.
final class CandidateSummaryView {
  const CandidateSummaryView({
    required this.kind,
    required this.direction,
    required this.lifecycle,
    required this.amountMinor,
    required this.amountCurrency,
    required this.confidenceBasisPoints,
    required this.requiresReview,
  });

  final String kind;
  final String direction;
  final String lifecycle;
  final int amountMinor;
  final String amountCurrency;
  final int confidenceBasisPoints;
  final bool requiresReview;

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
      );
    } catch (_) {
      return null;
    }
  }
}

final class InboxDetailData {
  const InboxDetailData({this.event, this.summary});

  final SmsEvent? event;
  final CandidateSummaryView? summary;
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
      return InboxDetailData(event: event, summary: summary);
    });

class InboxDetailPage extends ConsumerWidget {
  const InboxDetailPage({super.key, required this.smsEventId});

  final int smsEventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(inboxDetailProvider(smsEventId));
    return Scaffold(
      appBar: AppBar(title: const Text('Message')),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load message: $e')),
        data: (detail) {
          final event = detail.event;
          if (event == null) {
            return const Center(child: Text('Message not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                event.senderDisplay ?? event.senderKey,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${event.senderKey} · ${_formatTime(event.receivedAtEpochMs)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  // M4.16: review with the ORIGINAL message. The full
                  // normalized body is the primary display source; the masked
                  // preview is only a fallback for purged/filtered rows.
                  child: Text(
                    event.encryptedBody ?? event.redactedBody ?? '(no body)',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(status: event.status),
              ),
              if (detail.summary case final summary?) ...[
                const SizedBox(height: 16),
                _CandidateCard(summary: summary),
              ],
            ],
          );
        },
      ),
    );
  }

  String _formatTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.summary});

  final CandidateSummaryView summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Candidate summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ${_formatAmount(summary.amountMinor, summary.amountCurrency)}',
            ),
            Text('Confidence: ${summary.confidenceBasisPoints ~/ 100}%'),
            Text('Requires review: ${summary.requiresReview ? 'yes' : 'no'}'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _showReviewSheet(context),
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Review'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shrinkWrap: true,
        children: [
          Text(
            'Candidate review',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final (label, value) in [
            (
              'Amount',
              _formatAmount(summary.amountMinor, summary.amountCurrency),
            ),
            ('Kind', summary.kind),
            ('Direction', summary.direction),
            ('Lifecycle', summary.lifecycle),
            ('Confidence', '${summary.confidenceBasisPoints ~/ 100}%'),
            ('Requires review', summary.requiresReview ? 'yes' : 'no'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('$label: $value'),
            ),
          const SizedBox(height: 12),
          Text(
            'This summary is read-only. Approval and Wallet sync arrive with M5.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _formatAmount(int minorUnits, String code) {
    final sign = minorUnits < 0 ? '-' : '';
    final abs = minorUnits.abs();
    final whole = abs ~/ 100;
    final fraction = (abs % 100).toString().padLeft(2, '0');
    return '$sign$code $whole.$fraction';
  }
}
