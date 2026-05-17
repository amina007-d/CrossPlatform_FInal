import '../models/expense_model.dart';
import '../models/budget_settings.dart';
import '../models/shared_expense_model.dart';

// ─── Expense Repository ────────────────────────────────────────────────────

abstract class ExpenseRepository {
  Stream<List<ExpenseModel>> watchAllExpenses();
  Stream<List<ExpenseModel>> watchMonthlyExpenses(DateTime month);
  Future<double> getMonthlyTotal(DateTime month);
  Future<Map<String, double>> getCategoryTotals(DateTime month);
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(int id);
}

// ─── Budget Repository ─────────────────────────────────────────────────────

abstract class BudgetRepository {
  Future<BudgetSettings> getSettings();
  Future<void> saveSettings(BudgetSettings settings);
}

// ─── Currency Repository ───────────────────────────────────────────────────

abstract class CurrencyRepository {
  Future<Map<String, double>> getLatestRates(String base);
  Future<double> convert(double amount, String from, String to);
}

// ─── Household Repository ──────────────────────────────────────────────────

abstract class HouseholdRepository {
  Stream<List<SharedExpenseModel>> watchSharedExpenses(String householdId);
  Future<void> addSharedExpense(String householdId, SharedExpenseModel expense);
  Future<void> deleteSharedExpense(String householdId, String expenseId);
}
