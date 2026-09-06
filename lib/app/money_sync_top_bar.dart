import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_typography.dart';

/// The top bar shown on every shell tab: MoneySync logo + wordmark on the
/// left, bell + settings icons on the right, 2px divider at the bottom.
/// Matches the design prototype's `.top-bar` exactly.
class MoneySyncTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MoneySyncTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider(Theme.of(context).brightness),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo square
          Container(
            width: 30,
            height: 30,
            color: AppColors.text,
            alignment: Alignment.center,
            child: const Icon(
              Icons.sync,
              color: AppColors.bg,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          // Wordmark
          Text(
            'MoneySync',
            style: AppTypography.h5.copyWith(color: AppColors.text),
          ),
          const Spacer(),
          // Bell icon
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, size: 19),
            color: AppColors.accent,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 2),
          // Settings hamburger
          IconButton(
            key: const ValueKey('open-settings'),
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.tune, size: 19),
            color: AppColors.accent,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
