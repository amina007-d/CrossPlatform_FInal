import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(budgetSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile section
            _SectionHeader(title: 'Profile'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Your Name',
                      subtitle: settings.userName.isEmpty
                          ? 'Not set'
                          : settings.userName,
                      onTap: () => _editName(settings.userName),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Budget section
            _SectionHeader(title: 'Budget'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Monthly Budget Limit',
                      subtitle:
                          '${settings.monthlyLimit.toStringAsFixed(2)} ${settings.currency}',
                      onTap: () => _editBudget(settings.monthlyLimit),
                    ),
                    const Divider(),
                    _CurrencyDropdownTile(
                      currentCurrency: settings.currency,
                      onChanged: (currency) async {
                        await ref
                            .read(budgetSettingsProvider.notifier)
                            .updateSettings(
                                settings.copyWith(currency: currency));
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Appearance section
            _SectionHeader(title: 'Appearance'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _SettingsSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  value: settings.isDarkMode,
                  onChanged: (value) async {
                    await ref
                        .read(budgetSettingsProvider.notifier)
                        .updateSettings(
                            settings.copyWith(isDarkMode: value));
                    ref.read(themeModeProvider.notifier).state =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _editName(String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      final current = await ref.read(budgetSettingsProvider.future);
      await ref
          .read(budgetSettingsProvider.notifier)
          .updateSettings(current.copyWith(userName: result));
    }
  }

  Future<void> _editBudget(double current) async {
    final ctrl = TextEditingController(text: current.toStringAsFixed(2));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Monthly Budget Limit'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
          ),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, double.tryParse(ctrl.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      final current = await ref.read(budgetSettingsProvider.future);
      await ref
          .read(budgetSettingsProvider.notifier)
          .updateSettings(current.copyWith(monthlyLimit: result));
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _CurrencyDropdownTile extends StatelessWidget {
  final String currentCurrency;
  final ValueChanged<String> onChanged;

  const _CurrencyDropdownTile({
    required this.currentCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.currency_exchange,
          color: Theme.of(context).colorScheme.primary),
      title: const Text('Default Currency'),
      subtitle: Text(currentCurrency),
      trailing: DropdownButton<String>(
        value: currentCurrency,
        underline: const SizedBox(),
        items: AppConstants.currencies
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}