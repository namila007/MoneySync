import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/core/scheduling/auto_import_scheduler.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';

const _kPresets = [15, 30, 60];
const _kCustomSentinel = -1;

class AutoImportSettingsPage extends ConsumerStatefulWidget {
  const AutoImportSettingsPage({super.key});

  @override
  ConsumerState<AutoImportSettingsPage> createState() =>
      _AutoImportSettingsPageState();
}

class _AutoImportSettingsPageState
    extends ConsumerState<AutoImportSettingsPage> {
  late int _selectedMinutes;
  final _customController = TextEditingController();
  String? _customError;

  @override
  void initState() {
    super.initState();
    final configAsync = ref.read(_configurationStateProvider);
    _selectedMinutes = configAsync.value?.autoImportIntervalMinutes ?? 15;
    if (!_kPresets.contains(_selectedMinutes)) {
      _customController.text = _selectedMinutes.toString();
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(_configurationStateProvider);
    final enabled = configAsync.value?.autoImportEnabled ?? false;

    final effectiveGroupValue = _kPresets.contains(_selectedMinutes)
        ? _selectedMinutes
        : _kCustomSentinel;

    return Scaffold(
      appBar: AppBar(title: const Text('Auto-import')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _Section(
            title: 'Status',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.campaign_outlined),
                title: const Text('Auto-import'),
                subtitle: const Text(
                  'Periodically scan new messages from tracked senders',
                ),
                value: enabled,
                onChanged: (value) => _toggleAutoImport(value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Scan interval',
            children: [
              RadioGroup<int>(
                groupValue: effectiveGroupValue,
                onChanged: enabled
                    ? (v) {
                        if (v == null) return;
                        if (v == _kCustomSentinel) {
                          _showCustomDialog();
                        } else {
                          _selectInterval(v);
                        }
                      }
                    : (_) {},
                child: Column(
                  children: [
                    for (final minutes in _kPresets)
                      RadioListTile<int>(
                        title: Text(_labelForMinutes(minutes)),
                        value: minutes,
                      ),
                    RadioListTile<int>(
                      title: const Text('Custom'),
                      value: _kCustomSentinel,
                    ),
                  ],
                ),
              ),
              if (!_kPresets.contains(_selectedMinutes))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Every $_selectedMinutes minutes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelForMinutes(int minutes) {
    if (minutes == 60) return 'Every hour';
    return 'Every $minutes minutes';
  }

  Future<void> _toggleAutoImport(bool enabled) async {
    final repo = await ref.read(configurationRepositoryProvider.future);
    await repo.updateAutoImportEnabled(enabled);
    ref.invalidate(_configurationStateProvider);
    final scheduler = ref.read(autoImportSchedulerProvider);
    if (enabled) {
      await scheduler.enable(frequency: Duration(minutes: _selectedMinutes));
    } else {
      await scheduler.disable();
    }
  }

  Future<void> _selectInterval(int minutes) async {
    setState(() {
      _selectedMinutes = minutes;
      _customError = null;
      _customController.clear();
    });
    await _persistInterval(minutes);
  }

  Future<void> _showCustomDialog() async {
    _customController.clear();
    _customError = null;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Custom interval'),
          content: TextField(
            controller: _customController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Minutes',
              suffixText: 'minutes',
              errorText: _customError,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(_customController.text);
                if (value == null || value < 15) {
                  setDialogState(() {
                    _customError = 'Must be at least 15 minutes';
                  });
                  return;
                }
                Navigator.pop(context, value);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedMinutes = result;
        _customError = null;
      });
      await _persistInterval(result);
    }
  }

  Future<void> _persistInterval(int minutes) async {
    final repo = await ref.read(configurationRepositoryProvider.future);
    await repo.updateAutoImportIntervalMinutes(minutes);
    ref.invalidate(_configurationStateProvider);
    final configAsync = ref.read(_configurationStateProvider);
    final enabled = configAsync.value?.autoImportEnabled ?? false;
    if (enabled) {
      final scheduler = ref.read(autoImportSchedulerProvider);
      await scheduler.enable(frequency: Duration(minutes: minutes));
    }
  }
}

final _configurationStateProvider = FutureProvider<ConfigurationState>((ref) {
  return ref
      .watch(configurationRepositoryProvider.future)
      .then((repo) => repo.load());
});

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
