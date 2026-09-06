import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/app/theme/moneysync_theme.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_catalog_detail_screen.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_connection_controller.dart';

class WalletConnectionPage extends ConsumerStatefulWidget {
  const WalletConnectionPage({super.key});

  @override
  ConsumerState<WalletConnectionPage> createState() =>
      _WalletConnectionPageState();
}

class _WalletConnectionPageState extends ConsumerState<WalletConnectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(walletConnectionControllerProvider);
      if (state is WalletConnected && state.isStale) {
        ref.read(walletConnectionControllerProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletConnectionControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet connection'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: switch (state) {
          WalletPrerequisiteUnavailable() => const _BlockedBody(),
          WalletDisconnected() => const _DisconnectedBody(),
          WalletConnectionLoading(:final previous) => _LoadingOverlay(
            child: previous != null
                ? _bodyForState(previous)
                : const _DisconnectedBody(),
          ),
          WalletConnected(:final catalog, :final refreshedAt, :final isStale) =>
            _ConnectedBody(
              catalog: catalog,
              refreshedAt: refreshedAt,
              isStale: isStale,
            ),
          WalletConnectionFailure(:final userMessage) => _DisconnectedBody(
            failureMessage: userMessage,
          ),
        },
      ),
    );
  }

  Widget _bodyForState(WalletConnectionViewState state) => switch (state) {
    WalletConnected(:final catalog, :final refreshedAt, :final isStale) =>
      _ConnectedBody(
        catalog: catalog,
        refreshedAt: refreshedAt,
        isStale: isStale,
      ),
    WalletConnectionFailure(:final userMessage) => _DisconnectedBody(
      failureMessage: userMessage,
    ),
    _ => const _DisconnectedBody(),
  };
}

class _BlockedBody extends StatelessWidget {
  const _BlockedBody();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.account_balance_wallet_outlined,
          size: 48,
          color: AppColors.neutral400,
        ),
        const SizedBox(height: AppSpacing.s4),
        Text('Wallet connection', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.s2),
        Text(
          'Not available yet',
          style: AppTypography.body.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          'Secure storage and device authentication must be set up first.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.neutral500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      const Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: LinearProgressIndicator(),
      ),
    ],
  );
}

class _DisconnectedBody extends ConsumerStatefulWidget {
  const _DisconnectedBody({this.failureMessage});

  final String? failureMessage;

  @override
  ConsumerState<_DisconnectedBody> createState() => _DisconnectedBodyState();
}

class _DisconnectedBodyState extends ConsumerState<_DisconnectedBody> {
  final _tokenController = TextEditingController();
  var _submitting = false;
  String? _validationError;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final tokenText = _tokenController.text;
    final token = WalletToken.tryParse(tokenText);
    if (token == null) {
      setState(() => _validationError = 'Enter a valid Wallet token.');
      return;
    }

    final controller = ref.read(walletConnectionControllerProvider.notifier);
    final clearAfter = controller.canSubmitToken;
    final submit = controller.submit(token);
    if (clearAfter) _tokenController.clear();

    setState(() => _submitting = true);
    final result = await submit;
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _validationError = null;
    });

    if (result == WalletTokenSubmitResult.blocked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Token was not saved.')));
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      // Big title
      Text('Connect your\nwallet', style: AppTypography.display),
      const SizedBox(height: AppSpacing.s4),
      Text(
        'Paste your Wallet API token to link accounts, categories and targets.',
        style: AppTypography.body.copyWith(
          color: AppColors.neutral600,
        ),
      ),
      const SizedBox(height: AppSpacing.s6),

      // API token field
      Text(
        'API token',
        style: AppTypography.micro.copyWith(color: AppColors.neutral600),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: _tokenController,
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        autofillHints: const [],
        contextMenuBuilder: (_, _) => const SizedBox.shrink(),
        style: AppTypography.bodySmall,
        decoration: InputDecoration(
          hintText: 'Paste your Wallet API token',
          hintStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.neutral400,
          ),
          errorText: _validationError,
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
      ),
      const SizedBox(height: AppSpacing.s4),

      // Save & connect button
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _submitting ? null : _connect,
          child: Text(
            _submitting ? 'Connecting...' : 'Save & connect',
            style: AppTypography.label.copyWith(color: Colors.white),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.s4),

      // Info card
      Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: AppColors.surface),
        child: Text(
          'The Wallet API links MoneySync to your budgeting wallet so approved '
          'transactions post automatically.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ),

      if (widget.failureMessage != null) ...[
        const SizedBox(height: AppSpacing.s4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: AppColors.accent100),
          child: Row(
            children: [
              const Icon(Icons.error_outline, size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.failureMessage!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.accent800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

class _ConnectedBody extends ConsumerWidget {
  const _ConnectedBody({
    required this.catalog,
    required this.refreshedAt,
    required this.isStale,
  });

  final WalletCatalog catalog;
  final DateTime refreshedAt;
  final bool isStale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        // Status card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: AppColors.surface),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: isStale
                    ? MoneySyncTheme.of(context).warning
                    : MoneySyncTheme.of(context).success,
              ),
              const SizedBox(width: 8),
              Text(
                isStale ? 'Connected (offline)' : 'Connected',
                style: AppTypography.h5,
              ),
              const Spacer(),
              Text(
                isStale
                    ? 'cached ${DateTime.now().difference(refreshedAt).inMinutes}m ago'
                    : 'live',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s6),

        // Info rows
        _InfoRow(
          icon: Icons.account_balance,
          label: 'Accounts',
          value:
              '${catalog.accounts.length} \u00b7 refreshed ${_timeAgo(refreshedAt)}',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const WalletCatalogDetailScreen(
                mode: WalletCatalogDetailMode.accounts,
              ),
            ),
          ),
        ),
        _InfoRow(
          icon: Icons.category_outlined,
          label: 'Categories',
          value:
              '${catalog.categories.length} \u00b7 refreshed ${_timeAgo(refreshedAt)}',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const WalletCatalogDetailScreen(
                mode: WalletCatalogDetailMode.categories,
              ),
            ),
          ),
        ),
        _InfoRow(
          icon: Icons.check_circle_outline,
          label: 'Eligible targets',
          value:
              '${catalog.accounts.where((a) => a.eligibility == WalletAccountEligibility.eligible).length} accounts',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const WalletCatalogDetailScreen(
                mode: WalletCatalogDetailMode.eligibleTargets,
              ),
            ),
          ),
        ),

        // Divider
        Container(
          height: 2,
          color: AppColors.divider(Theme.of(context).brightness),
        ),
        const SizedBox(height: AppSpacing.s6),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleTest(context, ref),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Test connection'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleRefresh(context, ref),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh metadata'),
              ),
            ),
          ],
        ),

        // Divider
        Container(
          height: 2,
          color: AppColors.divider(Theme.of(context).brightness),
        ),
        const SizedBox(height: AppSpacing.s6),

        // API token + Processing
        _InfoRow(
          icon: Icons.vpn_key_outlined,
          label: 'API token',
          value: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
          trailing: GestureDetector(
            onTap: () => _handleReplace(context, ref),
            child: Text(
              'Replace',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.accent,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        _InfoRow(
          icon: Icons.settings_outlined,
          label: 'Processing default',
          value: 'Review',
        ),

        // Divider
        Container(
          height: 2,
          color: AppColors.divider(Theme.of(context).brightness),
        ),
        const SizedBox(height: AppSpacing.s6),

        // Disconnect button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _handleDisconnect(context, ref),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.accent, width: 2),
              foregroundColor: AppColors.accent,
            ),
            child: const Text('Disconnect Wallet'),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          'Disconnecting removes the stored token and cached metadata. '
          'It does not change inbox SMS or remote Wallet records.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.neutral500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _handleTest(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Testing connection...')));
    final controller = ref.read(walletConnectionControllerProvider.notifier);
    final result = await controller.refresh();
    if (!context.mounted) return;
    final message = switch (result) {
      WalletTokenSubmitResult.accepted => 'Connection successful.',
      WalletTokenSubmitResult.handedOff => 'Connection test failed.',
      WalletTokenSubmitResult.blocked => 'Test is not available right now.',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleRefresh(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Refreshing catalog...')));
    final controller = ref.read(walletConnectionControllerProvider.notifier);
    final result = await controller.refresh();
    if (!context.mounted) return;
    final message = switch (result) {
      WalletTokenSubmitResult.accepted => 'Catalog refreshed.',
      WalletTokenSubmitResult.handedOff => 'Refresh failed.',
      WalletTokenSubmitResult.blocked => 'Refresh is not available.',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleReplace(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace token?'),
        content: const Text(
          'This will require device authentication. '
          'The previous token will be revoked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(walletConnectionControllerProvider.notifier)
                  .submit(WalletToken.parse(''));
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _handleDisconnect(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect Wallet?'),
        content: const Text(
          'This will remove the stored token and cached metadata. '
          'Inbox SMS and remote Wallet records are not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final controller = ref.read(
                walletConnectionControllerProvider.notifier,
              );
              await controller.disconnect(confirmed: true);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: const BoxDecoration(color: AppColors.surface),
        margin: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.neutral700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.neutral400,
              ),
          ],
        ),
      ),
    );
  }
}
