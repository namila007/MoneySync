import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/security/foreground_lock.dart';

class LockPage extends ConsumerWidget {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(foregroundLockControllerProvider);
    final authAsync = ref.watch(freshAuthPortProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Unlock MoneySync',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your app lock is on. Local data remains encrypted even if you later turn off this app lock.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              authAsync.when(
                data: (auth) => switch (lockState) {
                  ForegroundLockState.authenticating => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ForegroundLockState.locked => FilledButton.icon(
                    onPressed: () async {
                      final notifier = ref.read(
                        foregroundLockControllerProvider.notifier,
                      );
                      await notifier.unlock(authenticator: auth);
                    },
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Unlock with device protection'),
                  ),
                  ForegroundLockState.unlocked => const Text(
                    'Unlocked',
                    textAlign: TextAlign.center,
                  ),
                  ForegroundLockState.lockedOut => Text(
                    'Too many attempts. Try again later.',
                    textAlign: TextAlign.center,
                  ),
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Text(
                  'Device authentication is not available.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              if (lockState == ForegroundLockState.locked)
                TextButton(onPressed: () {}, child: const Text('Need help?')),
            ],
          ),
        ),
      ),
    );
  }
}
