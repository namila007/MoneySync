import 'package:money_sync/features/transaction_parser/data/rule_packs/lk/lk_sampath_account_v1.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack.dart';

/// Single compiled manifest of rule packs. This directory is the only place a
/// bank may be named — see the bank-agnosticism architecture test
/// (`test/features/transaction_parser/architecture/bank_agnostic_test.dart`).
/// Adding a bank is one new pack file plus one line here; activation is data
/// (`rule_packs` table), never a pipeline change (M4.14 WP5).
const List<RulePack> allRulePacks = [lkSampathAccountV1];
