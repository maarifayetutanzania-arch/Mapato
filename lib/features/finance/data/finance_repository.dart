import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/finance_models.dart';

class FinanceRepository {
  FinanceRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Authentication is required.');
    return uid;
  }

  DocumentReference<Map<String, dynamic>> get _userDocument =>
      _firestore.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _userDocument.collection(name);

  Stream<List<CustomCategory>> watchCategories() => _collection('categories')
      .orderBy('name')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map(CustomCategory.fromSnapshot).toList(),
      );

  Future<void> saveCategory({
    required String id,
    required String name,
    required TransactionType type,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty || normalizedName.length > 32) {
      throw ArgumentError.value(
        name,
        'name',
        'Category name must be from 1 to 32 characters.',
      );
    }
    final reference = id.isEmpty
        ? _collection('categories').doc()
        : _collection('categories').doc(id);
    await reference.set({
      'name': normalizedName,
      'type': type.name,
      'updatedAt': FieldValue.serverTimestamp(),
      if (id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteCategory(String id) =>
      _collection('categories').doc(id).delete();

  Stream<List<FinanceTransaction>> watchTransactions({int limit = 50}) =>
      _collection('transactions')
          .orderBy('date', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map(FinanceTransaction.fromSnapshot).toList(),
          );

  Stream<List<FinanceTransaction>> watchRecentTransactions({int limit = 5}) =>
      watchTransactions(limit: limit);

  Future<List<FinanceTransaction>> exportTransactions({
    int pageSize = 250,
  }) async {
    if (pageSize < 1 || pageSize > 500) {
      throw ArgumentError.value(
        pageSize,
        'pageSize',
        'Page size must be from 1 to 500.',
      );
    }
    final collection = _collection('transactions');
    final results = <FinanceTransaction>[];
    DocumentSnapshot<Map<String, dynamic>>? cursor;
    while (true) {
      var query = collection.orderBy('date').limit(pageSize);
      if (cursor != null) query = query.startAfterDocument(cursor);
      final page = await query.get();
      results.addAll(page.docs.map(FinanceTransaction.fromSnapshot));
      if (page.docs.length < pageSize) return results;
      cursor = page.docs.last;
    }
  }

  Future<List<FinanceTransaction>> loadTransactionsAfter(
    String lastDocumentId, {
    int limit = 50,
  }) async {
    final collection = _collection('transactions');
    final cursor = await collection.doc(lastDocumentId).get();
    if (!cursor.exists) return const [];
    final page = await collection
        .orderBy('date', descending: true)
        .startAfterDocument(cursor)
        .limit(limit)
        .get();
    return page.docs.map(FinanceTransaction.fromSnapshot).toList();
  }

  Stream<FinanceSummary> watchSummary({String? monthKey}) =>
      _collection('summaries')
          .doc(monthKey ?? 'lifetime')
          .snapshots()
          .map((snapshot) => FinanceSummary.fromMap(snapshot.data()));

  Stream<List<Map<String, dynamic>>> watchMonthlySummaries({int months = 12}) =>
      _collection('summaries')
          .orderBy('monthKey', descending: true)
          .limit(months)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Future<void> saveTransaction(FinanceTransaction transaction) async {
    _validateTransaction(transaction);
    final collection = _collection('transactions');
    final creating = transaction.id.isEmpty;
    final reference = creating
        ? collection.doc()
        : collection.doc(transaction.id);
    await reference.set({
      ...transaction.toMap(creating: creating),
      'monthKey': _monthKey(transaction.date),
    }, SetOptions(merge: true));
  }

  Future<void> deleteTransaction(String id) =>
      _collection('transactions').doc(id).delete();

  Stream<List<BudgetRecord>> watchBudgets({String? monthKey}) =>
      _collection('budgets')
          .where('monthKey', isEqualTo: monthKey ?? _monthKey(DateTime.now()))
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.map(BudgetRecord.fromSnapshot).toList(),
          );

  Future<void> saveBudget({
    required String id,
    required String categoryId,
    required int amountMinor,
    required String currency,
    required String monthKey,
  }) async {
    if (amountMinor <= 0 || amountMinor > 1000000000000000) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Budget must be positive and within range.',
      );
    }
    final reference = id.isEmpty
        ? _collection('budgets').doc('${monthKey}_$categoryId')
        : _collection('budgets').doc(id);
    await reference.set({
      'categoryId': categoryId,
      'amountMinor': amountMinor,
      'currency': currency,
      'monthKey': monthKey,
      'updatedAt': FieldValue.serverTimestamp(),
      if (id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteBudget(String id) =>
      _collection('budgets').doc(id).delete();

  Stream<List<SavingsGoal>> watchGoals() => _collection('savingsGoals')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(SavingsGoal.fromSnapshot).toList());

  Future<void> saveGoal({
    required String id,
    required String name,
    required int targetMinor,
    required int currentMinor,
    required String currency,
    DateTime? targetDate,
  }) async {
    if (name.trim().isEmpty ||
        targetMinor <= 0 ||
        currentMinor < 0 ||
        currentMinor > targetMinor) {
      throw ArgumentError(
        'Goal name and valid target/current amounts are required.',
      );
    }
    final reference = id.isEmpty
        ? _collection('savingsGoals').doc()
        : _collection('savingsGoals').doc(id);
    await reference.set({
      'name': name.trim(),
      'targetMinor': targetMinor,
      'currentMinor': currentMinor,
      'currency': currency,
      'targetDate': targetDate == null ? null : Timestamp.fromDate(targetDate),
      'updatedAt': FieldValue.serverTimestamp(),
      if (id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateGoalAmount(String id, int deltaMinor) async {
    final reference = _collection('savingsGoals').doc(id);
    await _firestore.runTransaction((batch) async {
      final snapshot = await batch.get(reference);
      final data = snapshot.data();
      if (data == null) throw StateError('Goal not found.');
      final current = (data['currentMinor'] as num?)?.toInt() ?? 0;
      final target = (data['targetMinor'] as num?)?.toInt() ?? 0;
      final next = current + deltaMinor;
      if (deltaMinor == 0 || next < 0 || next > target) {
        throw ArgumentError(
          'The goal balance must remain between zero and its target.',
        );
      }
      batch.update(reference, {
        'currentMinor': next,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.set(reference.collection('history').doc(), {
        'deltaMinor': deltaMinor,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteGoal(String id) =>
      _collection('savingsGoals').doc(id).delete();

  Stream<List<GoalHistoryEntry>> watchGoalHistory(String goalId) =>
      _collection('savingsGoals')
          .doc(goalId)
          .collection('history')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map(GoalHistoryEntry.fromSnapshot).toList(),
          );

  Stream<List<DebtRecord>> watchDebts() => _collection('debts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(DebtRecord.fromSnapshot).toList());

  Future<void> saveDebt({
    required String id,
    required String name,
    required String person,
    required DebtDirection direction,
    required int amountMinor,
    required int paidMinor,
    required String currency,
    DateTime? dueDate,
    String note = '',
  }) async {
    if (name.trim().isEmpty ||
        amountMinor <= 0 ||
        paidMinor < 0 ||
        paidMinor > amountMinor) {
      throw ArgumentError(
        'Debt name and valid amount/paid values are required.',
      );
    }
    final reference = id.isEmpty
        ? _collection('debts').doc()
        : _collection('debts').doc(id);
    await reference.set({
      'name': name.trim(),
      'person': person.trim(),
      'direction': direction == DebtDirection.owedByMe
          ? 'owedByMe'
          : 'owedToMe',
      'amountMinor': amountMinor,
      'paidMinor': paidMinor,
      'currency': currency,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
      'note': note.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteDebt(String id) => _collection('debts').doc(id).delete();

  void _validateTransaction(FinanceTransaction transaction) {
    if (transaction.amountMinor <= 0 ||
        transaction.amountMinor > 1000000000000000) {
      throw ArgumentError.value(
        transaction.amountMinor,
        'amountMinor',
        'Amount must be positive and within range.',
      );
    }
    if (transaction.description.trim().isEmpty ||
        transaction.categoryId.trim().isEmpty) {
      throw ArgumentError('Transaction description and category are required.');
    }
  }

  String _monthKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
}
