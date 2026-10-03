import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

enum DebtDirection { owedByMe, owedToMe }

class CustomCategory {
  const CustomCategory({
    required this.id,
    required this.name,
    required this.type,
  });

  final String id;
  final String name;
  final TransactionType type;

  factory CustomCategory.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return CustomCategory(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
    );
  }
}

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.categoryId,
    required this.description,
    required this.date,
    this.note = '',
  });
  final String id;
  final TransactionType type;
  final int amountMinor;
  final String currency;
  final String categoryId;
  final String description;
  final DateTime date;
  final String note;

  factory FinanceTransaction.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return FinanceTransaction(
      id: snapshot.id,
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amountMinor: (data['amountMinor'] as num?)?.toInt() ?? 0,
      currency: data['currency'] as String? ?? 'TZS',
      categoryId: data['categoryId'] as String? ?? 'other',
      description: data['description'] as String? ?? '',
      date:
          (data['date'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      note: data['note'] as String? ?? '',
    );
  }

  Map<String, Object?> toMap({bool creating = false}) => {
    'type': type.name,
    'amountMinor': amountMinor,
    'currency': currency,
    'categoryId': categoryId,
    'description': description.trim(),
    'date': Timestamp.fromDate(date),
    'note': note.trim(),
    if (creating) 'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class FinanceSummary {
  const FinanceSummary({
    this.incomeMinor = 0,
    this.expenseMinor = 0,
    this.expenseByCategory = const {},
    this.incomeByCategory = const {},
  });

  final int incomeMinor;
  final int expenseMinor;
  final Map<String, int> expenseByCategory;
  final Map<String, int> incomeByCategory;

  int get balanceMinor => incomeMinor - expenseMinor;

  factory FinanceSummary.fromMap(Map<String, dynamic>? data) {
    Map<String, int> categoryAmounts(String field) {
      final values = data?[field];
      if (values is! Map) return const {};
      return values.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      );
    }

    return FinanceSummary(
      incomeMinor: (data?['incomeMinor'] as num?)?.toInt() ?? 0,
      expenseMinor: (data?['expenseMinor'] as num?)?.toInt() ?? 0,
      expenseByCategory: categoryAmounts('expenseByCategory'),
      incomeByCategory: categoryAmounts('incomeByCategory'),
    );
  }
}

class BudgetRecord {
  const BudgetRecord({
    required this.id,
    required this.categoryId,
    required this.amountMinor,
    required this.currency,
    required this.monthKey,
  });

  final String id;
  final String categoryId;
  final int amountMinor;
  final String currency;
  final String monthKey;

  factory BudgetRecord.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return BudgetRecord(
      id: snapshot.id,
      categoryId: data['categoryId'] as String? ?? 'other',
      amountMinor: (data['amountMinor'] as num?)?.toInt() ?? 0,
      currency: data['currency'] as String? ?? 'TZS',
      monthKey: data['monthKey'] as String? ?? '',
    );
  }
}

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetMinor,
    required this.currentMinor,
    required this.currency,
    this.targetDate,
  });

  final String id;
  final String name;
  final int targetMinor;
  final int currentMinor;
  final String currency;
  final DateTime? targetDate;

  factory SavingsGoal.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return SavingsGoal(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      targetMinor: (data['targetMinor'] as num?)?.toInt() ?? 0,
      currentMinor: (data['currentMinor'] as num?)?.toInt() ?? 0,
      currency: data['currency'] as String? ?? 'TZS',
      targetDate: (data['targetDate'] as Timestamp?)?.toDate(),
    );
  }
}

class GoalHistoryEntry {
  const GoalHistoryEntry({
    required this.id,
    required this.deltaMinor,
    required this.date,
  });

  final String id;
  final int deltaMinor;
  final DateTime? date;

  factory GoalHistoryEntry.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return GoalHistoryEntry(
      id: snapshot.id,
      deltaMinor: (data['deltaMinor'] as num?)?.toInt() ?? 0,
      date: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class DebtRecord {
  const DebtRecord({
    required this.id,
    required this.name,
    required this.person,
    required this.direction,
    required this.amountMinor,
    required this.paidMinor,
    required this.currency,
    this.dueDate,
    this.note = '',
  });

  final String id;
  final String name;
  final String person;
  final DebtDirection direction;
  final int amountMinor;
  final int paidMinor;
  final String currency;
  final DateTime? dueDate;
  final String note;

  int get remainingMinor => amountMinor - paidMinor;

  factory DebtRecord.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return DebtRecord(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      person: data['person'] as String? ?? '',
      direction: data['direction'] == 'owedToMe'
          ? DebtDirection.owedToMe
          : DebtDirection.owedByMe,
      amountMinor: (data['amountMinor'] as num?)?.toInt() ?? 0,
      paidMinor: (data['paidMinor'] as num?)?.toInt() ?? 0,
      currency: data['currency'] as String? ?? 'TZS',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      note: data['note'] as String? ?? '',
    );
  }
}
