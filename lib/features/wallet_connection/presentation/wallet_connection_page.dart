import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';
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
          WalletDisconnected() => const _TokenEntry(),
          WalletConnectionLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          WalletConnected() => const _StatusBody('Wallet connection is ready'),
          WalletConnectionFailure(:final userMessage) => _StatusBody(
            userMessage,
          ),
        },
      ),
    );
  }
}

class _BlockedBody extends StatelessWidget {
  const _BlockedBody();

  @override
  Widget build(BuildContext context) => const _StatusBody(
    'Wallet connection is not available yet',
    detail:
        'Secure storage and fresh device authentication must be completed first.',
  );
}

class _StatusBody extends StatelessWidget {
  const _StatusBody(this.title, {this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (detail != null) ...[const SizedBox(height: 12), Text(detail!)],
      ],
    ),
  );
}

class _TokenEntry extends ConsumerStatefulWidget {
  const _TokenEntry();

  @override
  ConsumerState<_TokenEntry> createState() => _TokenEntryState();
}

class _TokenEntryState extends ConsumerState<_TokenEntry> {
  final _controller = TextEditingController();
  var _submitting = false;
  String? _validationError;

  @override
  void dispose() {
    _controller.clear();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final tokenText = _controller.text;
    final token = switch (WalletToken.tryParse(tokenText)) {
      final WalletToken value => value,
      null => null,
    };
    if (token == null) {
      setState(() => _validationError = 'Enter a valid Wallet token.');
      return;
    }
    setState(() => _submitting = true);
    final controller = ref.read(walletConnectionControllerProvider.notifier);
    final result = await controller.submit(token);
    if (!mounted) return;
    if (result == WalletTokenSubmitResult.accepted) {
      _controller.clear();
      setState(() => _submitting = false);
      return;
    }
    setState(() => _submitting = false);
    if (result == WalletTokenSubmitResult.blocked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Token was not saved.')));
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Connect Wallet'),
      const SizedBox(height: 12),
      TextField(
        controller: _controller,
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        autofillHints: const <String>[],
        contextMenuBuilder: (context, editableTextState) =>
            const SizedBox.shrink(),
        decoration: InputDecoration(
          labelText: 'Wallet token',
          errorText: _validationError,
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _submitting ? null : _save,
        child: const Text('Save token'),
      ),
    ],
  );
}
