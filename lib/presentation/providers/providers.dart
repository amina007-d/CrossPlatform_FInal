import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/dao/expense_dao.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../data/repositories/currency_repository_impl.dart';
import '../../data/repositories/household_repository_impl.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/models/budget_settings.dart';
import '../../domain/models/shared_expense_model.dart';
import '../../domain/repositories/repositories.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final expenseDaoProvider = Provider<ExpenseDao>((ref) {
  return ExpenseDao(ref.watch(databaseProvider));
});


final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(expenseDaoProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl();
});

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyRepositoryImpl();
});

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepositoryImpl();
});


final budgetSettingsProvider =
    AsyncNotifierProvider<BudgetNotifier, BudgetSettings>(BudgetNotifier.new);

class BudgetNotifier extends AsyncNotifier<BudgetSettings> {
  @override
  Future<BudgetSettings> build() async {
    return ref.watch(budgetRepositoryProvider).getSettings();
  }

  Future<void> updateSettings(BudgetSettings settings) async {
    state = const AsyncLoading();
    await ref.watch(budgetRepositoryProvider).saveSettings(settings);
    state = AsyncData(settings);
  }
}

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final monthlyExpensesProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(expenseRepositoryProvider).watchMonthlyExpenses(month);
});

final allExpensesProvider = StreamProvider<List<ExpenseModel>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAllExpenses();
});

final monthlyTotalProvider = StreamProvider<double>((ref) {
  final month = ref.watch(selectedMonthProvider);
  // Derive total from the live stream of expenses
  return ref
      .watch(expenseRepositoryProvider)
      .watchMonthlyExpenses(month)
      .map((expenses) =>
          expenses.fold<double>(0.0, (sum, e) => sum + e.amount));
});

final categoryTotalsProvider = StreamProvider<Map<String, double>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref
      .watch(expenseRepositoryProvider)
      .watchMonthlyExpenses(month)
      .map((expenses) {
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  });
});


final selectedFromCurrencyProvider = StateProvider<String>((ref) => 'USD');
final selectedToCurrencyProvider = StateProvider<String>((ref) => 'EUR');
final conversionAmountProvider = StateProvider<double>((ref) => 1.0);

final currencyRatesProvider =
    FutureProvider.family<Map<String, double>, String>(
  (ref, base) => ref.watch(currencyRepositoryProvider).getLatestRates(base),
);

final conversionResultProvider = FutureProvider<double>((ref) {
  final amount = ref.watch(conversionAmountProvider);
  final from = ref.watch(selectedFromCurrencyProvider);
  final to = ref.watch(selectedToCurrencyProvider);
  return ref.watch(currencyRepositoryProvider).convert(amount, from, to);
});


final householdIdProvider = StateProvider<String>((ref) => '');

final sharedExpensesProvider =
    StreamProvider<List<SharedExpenseModel>>((ref) {
  final householdId = ref.watch(householdIdProvider);
  return ref
      .watch(householdRepositoryProvider)
      .watchSharedExpenses(householdId);
});