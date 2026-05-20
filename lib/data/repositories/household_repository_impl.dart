import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/shared_expense_model.dart';
import '../../domain/repositories/repositories.dart';

class HouseholdRepositoryImpl implements HouseholdRepository {
  final FirebaseFirestore _firestore;

  HouseholdRepositoryImpl() : _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sharedExpensesRef(
          String householdId) =>
      _firestore
          .collection(AppConstants.householdsCollection)
          .doc(householdId)
          .collection(AppConstants.sharedExpensesSubcollection);

  @override
  Stream<List<SharedExpenseModel>> watchSharedExpenses(String householdId) {
    if (householdId.isEmpty) return Stream.value([]);
    return _sharedExpensesRef(householdId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SharedExpenseModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> addSharedExpense(
      String householdId, SharedExpenseModel expense) async {
    await _sharedExpensesRef(householdId).add(expense.toFirestore());
  }

  @override
  Future<void> deleteSharedExpense(
      String householdId, String expenseId) async {
    await _sharedExpensesRef(householdId).doc(expenseId).delete();
  }
}