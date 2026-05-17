import 'package:drift/drift.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/dao/expense_dao.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/repositories.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDao _dao;

  ExpenseRepositoryImpl(this._dao);

  @override
  Stream<List<ExpenseModel>> watchAllExpenses() =>
      _dao.watchAllExpenses().map((list) => list.map(_toModel).toList());

  @override
  Stream<List<ExpenseModel>> watchMonthlyExpenses(DateTime month) => _dao
      .watchMonthlyExpenses(month)
      .map((list) => list.map(_toModel).toList());

  @override
  Future<double> getMonthlyTotal(DateTime month) => _dao.getMonthlyTotal(month);

  @override
  Future<Map<String, double>> getCategoryTotals(DateTime month) =>
      _dao.getCategoryTotals(month);

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await _dao.insertExpense(
      ExpensesCompanion(
        title: Value(expense.title),
        amount: Value(expense.amount),
        category: Value(expense.category),
        currency: Value(expense.currency),
        note: Value(expense.note),
        date: Value(expense.date),
      ),
    );
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final existing = await _dao.getExpenseById(expense.id!);
    if (existing == null) return;
    await _dao.updateExpense(
      existing.copyWith(
        title: expense.title,
        amount: expense.amount,
        category: expense.category,
        currency: expense.currency,
        note: Value(expense.note),
        date: expense.date,
      ),
    );
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _dao.deleteExpense(id);
  }

  ExpenseModel _toModel(Expense e) => ExpenseModel(
    id: e.id,
    title: e.title,
    amount: e.amount,
    category: e.category,
    currency: e.currency,
    note: e.note,
    date: e.date,
    createdAt: e.createdAt,
  );
}
