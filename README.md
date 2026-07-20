# Money Sync

Android-first, local-first Flutter application for reviewing transaction messages and synchronizing approved records with BudgetBakers Wallet.

The application now contains the M0 architecture shell: Riverpod composition, typed routing, five Material 3 destinations, fail-closed capability configuration, and permission-free `playManual` and `privateFull` Android flavors. Sensitive-data handling, Wallet writes, SMS access, ML, and automation are not implemented or enabled yet.

Start here:

- App contribution rules: [`AGENTS.MD`](./AGENTS.MD)
- Product and architecture plan: [MoneySync guides](https://github.com/namila007/moneysync-guides/tree/master/plan)
- Milestone implementation order: [implementation milestones](https://github.com/namila007/moneysync-guides/tree/master/milestone)
- Quality gates: [cross-cutting quality gates](https://github.com/namila007/moneysync-guides/blob/master/milestone/quality-gates.md)

M0 verification:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage --branch-coverage
flutter build apk --debug --flavor playManual -t lib/main_play_manual.dart
flutter build apk --debug --flavor privateFull -t lib/main_private_full.dart
bash tool/verify_android_permissions.sh \
  build/app/outputs/flutter-apk/app-playmanual-debug.apk \
  build/app/outputs/flutter-apk/app-privatefull-debug.apk
```

Coverage is informational for M0 placeholder/framework boilerplate. The tests protect the actual shell, capability, accessibility, and bootstrap contracts.

The private `plan/sms.txt` source file from the guides workspace must never be used as a fixture or copied into application artifacts. Only redacted or synthetic messages may be committed.
