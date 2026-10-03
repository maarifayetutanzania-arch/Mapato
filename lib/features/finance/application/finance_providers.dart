import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/finance_repository.dart';
import '../domain/finance_models.dart';

final financeRepositoryProvider = Provider<FinanceRepository>(
  (ref) => FinanceRepository(),
);

final transactionsProvider = StreamProvider<List<FinanceTransaction>>((ref) {
  if (ref.watch(currentUserProvider) == null) return Stream.value(const []);
  return ref.watch(financeRepositoryProvider).watchTransactions();
});

final recentTransactionsProvider = StreamProvider<List<FinanceTransaction>>((
  ref,
) {
  if (ref.watch(currentUserProvider) == null) return Stream.value(const []);
  return ref.watch(financeRepositoryProvider).watchRecentTransactions();
});

final currentMonthSummaryProvider = StreamProvider<FinanceSummary>((ref) {
  if (ref.watch(currentUserProvider) == null) {
    return Stream.value(const FinanceSummary());
  }
  final now = DateTime.now();
  final key =
      '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
  return ref.watch(financeRepositoryProvider).watchSummary(monthKey: key);
});

final lifetimeSummaryProvider = StreamProvider<FinanceSummary>((ref) {
  if (ref.watch(currentUserProvider) == null) {
    return Stream.value(const FinanceSummary());
  }
  return ref.watch(financeRepositoryProvider).watchSummary();
});

final budgetsProvider = StreamProvider<List<BudgetRecord>>((ref) {
  if (ref.watch(currentUserProvider) == null) return Stream.value(const []);
  return ref.watch(financeRepositoryProvider).watchBudgets();
});

final savingsGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  if (ref.watch(currentUserProvider) == null) return Stream.value(const []);
  return ref.watch(financeRepositoryProvider).watchGoals();
});

final debtsProvider = StreamProvider<List<DebtRecord>>((ref) {
  if (ref.watch(currentUserProvider) == null) return Stream.value(const []);
  return ref.watch(financeRepositoryProvider).watchDebts();
});

final monthlySummariesProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  if (ref.watch(currentUserProvider) == null) return Stream.value(const []);
  return ref.watch(financeRepositoryProvider).watchMonthlySummaries();
});

final customCategoriesProvider = StreamProvider<List<CustomCategory>>((ref) {
  if (ref.watch(currentUserProvider) == null) return Stream.value(const []);
  return ref.watch(financeRepositoryProvider).watchCategories();
});
