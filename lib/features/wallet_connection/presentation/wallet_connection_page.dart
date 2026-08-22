import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_catalog_detail_screen.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_connection_controller.dart';

class WalletConnectionPage extends ConsumerWidget {
  const WalletConnectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletConnectionControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet connection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (state) {
          WalletPrerequisiteUnavailable() => const _BlockedBody(),
          WalletDisconnected() => const _DisconnectedBody(),
          WalletConnectionLoading() => const _LoadingBody(),
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
}

class _BlockedBody extends StatelessWidget {
  const _BlockedBody();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.account_balance_wallet_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          'Wallet connection',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Not available yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Secure storage and device authentication must be set up first.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Connecting...'),
      ],
    ),
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
      const SizedBox(height: 16),
      if (widget.failureMessage != null) ...[
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.failureMessage!)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      Text('Connect Wallet', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(
        'Enter your personal Wallet API token. It will be stored securely in device Keystore.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _tokenController,
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        autofillHints: const [],
        contextMenuBuilder: (_, _) => const SizedBox.shrink(),
        decoration: InputDecoration(
          labelText: 'API token',
          errorText: _validationError,
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _submitting ? null : _connect,
        icon: const Icon(Icons.link),
        label: Text(_submitting ? 'Connecting...' : 'Save & connect'),
      ),
      const SizedBox(height: 24),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Wallet API',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'You need a Wallet Premium account. Generate a personal API token in your Wallet web app settings under Integrations > REST API.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
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
        _StatusHeader(isStale: isStale, refreshedAt: refreshedAt),
        const Divider(height: 24),
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
        const SizedBox(height: 8),
        _InfoRow(
          icon: Icons.category,
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
        const SizedBox(height: 8),
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
        const Divider(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleTest(context, ref),
                icon: const Icon(Icons.wifi_find, size: 18),
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
        const Divider(height: 24),
        ListTile(
          leading: const Icon(Icons.vpn_key_outlined),
          title: const Text('API token'),
          subtitle: const Text(
            '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
          ),
          trailing: TextButton(
            onPressed: () => _handleReplace(context, ref),
            child: const Text('Replace'),
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Processing default'),
          subtitle: const Text('Review'),
        ),
        const Divider(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _handleDisconnect(context, ref),
            icon: const Icon(Icons.link_off),
            label: const Text('Disconnect Wallet'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Disconnecting removes the stored token and cached metadata. '
          'It does not change inbox SMS or remote Wallet records.',
          style: Theme.of(context).textTheme.bodySmall,
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.isStale, required this.refreshedAt});

  final bool isStale;
  final DateTime refreshedAt;

  @override
  Widget build(BuildContext context) {
    final color = isStale ? Colors.amber : Colors.green;
    final label = isStale ? 'Connected (offline)' : 'Connected';
    final diff = DateTime.now().difference(refreshedAt);

    return Row(
      children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Text(
          isStale ? 'cached ${diff.inMinutes}m ago' : 'live',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      dense: true,
      onTap: onTap,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, size: 20)
          : null,
    );
  }
}
