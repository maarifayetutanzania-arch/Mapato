abstract final class FinancialCalculations {
  static int total(Iterable<int> amounts) =>
      amounts.fold<int>(0, (sum, amount) => sum + amount);

  static int balance({required int income, required int expenses}) => income - expenses;

  static int savings({required int income, required int expenses}) =>
      balance(income: income, expenses: expenses);

  static double? savingsRate({required int income, required int expenses}) {
    if (income <= 0) return null;
    return (income - expenses) / income * 100;
  }

  static int budgetRemaining({required int budget, required int spent}) =>
      budget - spent;

  static double goalProgress({required int current, required int target}) {
    if (target <= 0 || current <= 0) return 0;
    return (current / target).clamp(0, 1).toDouble();
  }

  static double budgetProgress({required int spent, required int budget}) {
    if (budget <= 0 || spent <= 0) return 0;
    return (spent / budget).clamp(0, 1).toDouble();
  }
}
