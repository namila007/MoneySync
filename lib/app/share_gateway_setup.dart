import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/sms_ingestion/data/manual_share_gateway.dart';
import 'package:money_sync/features/sms_ingestion/data/share_intent_pigeon.g.dart';
import 'package:money_sync/features/sms_ingestion/presentation/share_intent_controller.dart';

class ShareGatewaySetup extends ConsumerStatefulWidget {
  const ShareGatewaySetup({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShareGatewaySetup> createState() => _ShareGatewaySetupState();
}

class _ShareGatewaySetupState extends ConsumerState<ShareGatewaySetup> {
  @override
  void initState() {
    super.initState();
    final gateway = ManualShareGateway(
      onSharedTextReceived: (payload) {
        ref.read(shareIntentProvider.notifier).handleSharedText(payload);
      },
    );
    ShareIntentFlutterApi.setUp(gateway);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
