import 'package:money_sync/features/transaction_parser/domain/rule_pack.dart';

/// Registry of versioned rule packs. Packs are **data**: a new bank (or a new
/// product family of an existing bank) is registered here with zero pipeline
/// changes. Selection is deterministic: sender match first, then discriminator
/// specificity, then pack id ascending — a tie yields [RulePackSelectionTie].
final class RulePackRegistry {
  RulePackRegistry({required List<RulePack> packs})
    : _packs = List.unmodifiable(packs);

  final List<RulePack> _packs;

  List<RulePack> get packs => _packs;

  RulePackSelection select({required String body, required String sender}) {
    final normalizedSender = sender.trim().toUpperCase();

    final candidates = _packs.where((pack) {
      final senderMatches = pack.senderPatterns.any(
        (pattern) => normalizedSender.contains(pattern.toUpperCase()),
      );
      final discriminatorsMatch =
          pack.discriminators.isNotEmpty &&
          pack.discriminators.every((d) => _discriminatorIn(body, d));
      return senderMatches || discriminatorsMatch;
    }).toList();

    if (candidates.isEmpty) return const RulePackSelectionNone();

    candidates.sort(_comparePacks);
    final best = candidates.first;
    final tied = candidates.where((p) => _comparePacks(p, best) == 0).length;
    if (tied > 1) {
      return RulePackSelectionTie([...candidates.take(tied)]);
    }
    return RulePackSelectionMatch(best);
  }

  bool _discriminatorIn(String body, Discriminator d) {
    final index = body.indexOf(d.token);
    return switch (d.anchor) {
      Anchor.anywhere => index >= 0,
      Anchor.lineStart => index == 0 || body[index - 1] == '\n',
      Anchor.lineEnd =>
        index >= 0 && (index == body.length - 1 || body[index + 1] == '\n'),
    };
  }

  int _comparePacks(RulePack a, RulePack b) {
    final discriminatorDiff = b.discriminators.length - a.discriminators.length;
    if (discriminatorDiff != 0) return discriminatorDiff;
    return a.id.compareTo(b.id);
  }
}

sealed class RulePackSelection {
  const RulePackSelection();
}

final class RulePackSelectionMatch extends RulePackSelection {
  const RulePackSelectionMatch(this.pack);
  final RulePack pack;
}

/// Two or more packs tied at the same specificity — never pick arbitrarily.
final class RulePackSelectionTie extends RulePackSelection {
  const RulePackSelectionTie(this.tiedPacks);
  final List<RulePack> tiedPacks;
}

final class RulePackSelectionNone extends RulePackSelection {
  const RulePackSelectionNone();
}
