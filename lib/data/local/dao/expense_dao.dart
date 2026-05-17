import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  Stream<List<Expense>> watchAllExpenses() =>
      (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Stream<List<Expense>> watchMonthlyExpenses(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return (select(expenses)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<Expense>> watchByCategory(String category) =>
      (select(expenses)
            ..where((t) => t.category.equals(category))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<double> getMonthlyTotal(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final query = select(expenses)
      ..where((t) => t.date.isBetweenValues(start, end));
    final result = await query.get();
    return result.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  Future<Map<String, double>> getCategoryTotals(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final query = select(expenses)
      ..where((t) => t.date.isBetweenValues(start, end));
    final result = await query.get();
    final Map<String, double> totals = {};
    for (final e in result) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<bool> updateExpense(Expense expense) =>
      update(expenses).replace(expense);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();

  Future<Expense?> getExpenseById(int id) =>
      (select(expenses)..where((t) => t.id.equals(id))).getSingleOrNull();
}