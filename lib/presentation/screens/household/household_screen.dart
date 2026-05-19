import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/shared_expense_model.dart';
import '../../providers/providers.dart';

class HouseholdScreen extends ConsumerStatefulWidget {
  const HouseholdScreen({super.key});

  @override
  ConsumerState<HouseholdScreen> createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends ConsumerState<HouseholdScreen> {
  @override
  void initState() {
    super.initState();
    // Load household ID from settings
    Future.microtask(() async {
      final settings = await ref.read(budgetSettingsProvider.future);
      if (settings.householdId.isNotEmpty) {
        ref.read(householdIdProvider.notifier).state = settings.householdId;
      }
    });
  }

  Future<void> _showAddExpenseDialog() async {
    final householdId = ref.read(householdIdProvider);
    if (householdId.isEmpty) {
      _showSetHouseholdDialog();
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String category = AppConstants.categories.first;
    String currency = 'USD';

    final budgetSettings = await ref.read(budgetSettingsProvider.future);
    final userName = budgetSettings.userName;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Shared Expense'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Title', border: OutlineInputBorder()),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: amountCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (double.tryParse(v) == null)
                              return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: currency,
                        items: AppConstants.currencies
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => currency = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder()),
                    items: AppConstants.categories
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                                '${AppConstants.categoryEmojis[c] ?? ''} $c')))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => category = v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final expense = SharedExpenseModel(
                  title: titleCtrl.text.trim(),
                  amount: double.parse(amountCtrl.text),
                  currency: currency,
                  category: category,
                  paidBy: userName.isEmpty ? 'Me' : userName,
                  note: noteCtrl.text.trim().isEmpty
                      ? null
                      : noteCtrl.text.trim(),
                  date: DateTime.now(),
                  splitBetween: [userName.isEmpty ? 'Me' : userName],
                );
                await ref
                    .read(householdRepositoryProvider)
                    .addSharedExpense(householdId, expense);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetHouseholdDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Household ID'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Household ID',
            hintText: 'e.g. my-family-2024',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              ref.read(householdIdProvider.notifier).state = ctrl.text;
              final current = await ref.read(budgetSettingsProvider.future);
              await ref
                  .read(budgetRepositoryProvider)
                  .saveSettings(current.copyWith(householdId: ctrl.text));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final householdId = ref.watch(householdIdProvider);
    final sharedExpensesAsync = ref.watch(sharedExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Household'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: _showSetHouseholdDialog,
            tooltip: 'Set Household ID',
          ),
        ],
      ),
      body: householdId.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No household set',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set a household ID to share expenses with your family',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _showSetHouseholdDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Set Household ID'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.home,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Household: $householdId',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: sharedExpensesAsync.when(
                    data: (expenses) => expenses.isEmpty
                        ? const Center(
                            child: Text('No shared expenses yet',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: expenses.length,
                            itemBuilder: (context, index) =>
                                _SharedExpenseTile(expense: expenses[index]),
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Shared'),
      ),
    );
  }
}

class _SharedExpenseTile extends ConsumerWidget {
  final SharedExpenseModel expense;

  const _SharedExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          child: Text(
            AppConstants.categoryEmojis[expense.category] ?? '💰',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(expense.title,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paid by: ${expense.paidBy}',
                style: Theme.of(context).textTheme.bodySmall),
            Text(DateFormatter.formatDate(expense.date),
                style: Theme.of(context).textTheme.bodySmall),
            if (expense.splitBetween.length > 1)
              Text(
                '${CurrencyFormatter.format(expense.perPersonAmount, expense.currency)}/person',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(expense.amount, expense.currency),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () async {
                final householdId = ref.read(householdIdProvider);
                await ref
                    .read(householdRepositoryProvider)
                    .deleteSharedExpense(householdId, expense.id!);
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
