import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';

sealed class WalletConnectionViewState {
  const WalletConnectionViewState();
}

final class WalletPrerequisiteUnavailable extends WalletConnectionViewState {
  const WalletPrerequisiteUnavailable();
}

final class WalletDisconnected extends WalletConnectionViewState {
  const WalletDisconnected();
}

final class WalletConnectionLoading extends WalletConnectionViewState {
  const WalletConnectionLoading();
}

final class WalletConnected extends WalletConnectionViewState {
  const WalletConnected();
}

enum WalletConnectionProblemCode {
  invalidToken,
  initialSync,
  rateLimited,
  offlineCached,
  timeout,
  tls,
  service,
}

final class WalletConnectionFailure extends WalletConnectionViewState {
  const WalletConnectionFailure(this.code);

  final WalletConnectionProblemCode code;

  String get userMessage => switch (code) {
    WalletConnectionProblemCode.invalidToken => 'Enter a valid Wallet token.',
    WalletConnectionProblemCode.initialSync => 'Wallet is preparing its data.',
    WalletConnectionProblemCode.rateLimited =>
      'Wallet is rate limited. Try again later.',
    WalletConnectionProblemCode.offlineCached =>
      'Wallet is offline. Cached data may be shown.',
    WalletConnectionProblemCode.timeout => 'Wallet connection timed out.',
    WalletConnectionProblemCode.tls =>
      'Wallet connection could not be verified.',
    WalletConnectionProblemCode.service => 'Wallet is temporarily unavailable.',
  };
}

enum WalletTokenSubmitResult { accepted, blocked }

final walletConnectionControllerProvider =
    NotifierProvider<WalletConnectionController, WalletConnectionViewState>(
      WalletConnectionController.new,
    );

/// Production stays blocked until secure storage and fresh device auth exist.
class WalletConnectionController extends Notifier<WalletConnectionViewState> {
  @override
  WalletConnectionViewState build() => const WalletPrerequisiteUnavailable();

  Future<WalletTokenSubmitResult> submit(WalletToken token) async =>
      WalletTokenSubmitResult.blocked;
}
