import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/expense_model.dart';
import '../../providers/providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? editExpense;

  const AddExpenseScreen({super.key, this.editExpense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;

  bool get _isEditing => widget.editExpense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editExpense;
    _titleCtrl = TextEditingController(text: e?['title'] ?? '');
    _amountCtrl = TextEditingController(
        text: e != null ? (e['amount'] as double).toStringAsFixed(2) : '');
    _noteCtrl = TextEditingController(text: e?['note'] ?? '');
    _selectedCategory = e?['category'] ?? AppConstants.categories.first;
    _selectedDate = e != null
        ? DateTime.parse(e['date'] as String)
        : DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final settings = await ref.read(budgetSettingsProvider.future);
      final currency = settings.currency;

      final expense = ExpenseModel(
        id: widget.editExpense?['id'] as int?,
        title: _titleCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text),
        category: _selectedCategory,
        currency: currency,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        date: _selectedDate,
      );

      final repo = ref.read(expenseRepositoryProvider);
      if (_isEditing) {
        await repo.updateExpense(expense);
      } else {
        await repo.addExpense(expense);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetAsync = ref.watch(budgetSettingsProvider);
    final currency = budgetAsync.whenData((s) => s.currency).value ?? 'USD';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter a title' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountCtrl,
              decoration: InputDecoration(
                labelText: 'Amount ($currency)',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter amount';
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: AppConstants.categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                            '${AppConstants.categoryEmojis[c] ?? ''} $c'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),

            // Date
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('MMMM dd, yyyy').format(_selectedDate),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Note
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Submit
            FilledButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isEditing ? Icons.save : Icons.add),
              label: Text(_isEditing ? 'Save Changes' : 'Add Expense'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}