import 'package:flutter_test/flutter_test.dart';
import 'package:mapato_binafsi/core/utils/financial_calculations.dart';
import 'package:mapato_binafsi/core/utils/money.dart';

void main() {
  group('FinancialCalculations', () {
    test('calculates net balance and savings from integer minor units', () {
      expect(FinancialCalculations.balance(income: 3500000, expenses: 1200000), 2300000);
      expect(FinancialCalculations.savings(income: 3500000, expenses: 1200000), 2300000);
    });

    test('does not report a savings rate without income', () {
      expect(FinancialCalculations.savingsRate(income: 0, expenses: 100), isNull);
    });

    test('supports a negative cash flow and negative remaining budget', () {
      expect(FinancialCalculations.balance(income: 100, expenses: 150), -50);
      expect(FinancialCalculations.budgetRemaining(budget: 100, spent: 150), -50);
    });

    test('clamps progress for overfunded goals and overspent budgets', () {
      expect(FinancialCalculations.goalProgress(current: 120, target: 100), 1);
      expect(FinancialCalculations.budgetProgress(spent: 120, budget: 100), 1);
    });

    test('returns zero progress for missing or zero targets', () {
      expect(FinancialCalculations.goalProgress(current: 10, target: 0), 0);
      expect(FinancialCalculations.budgetProgress(spent: 10, budget: 0), 0);
    });

    test('parses whole-unit and decimal currencies without floating point', () {
      expect(Money.parseMinor('12,500', 'TZS'), 12500);
      expect(Money.parseMinor('12.34', 'USD'), 1234);
      expect(Money.parseMinor('12.345', 'USD'), isNull);
      expect(Money.parseMinor('12.5', 'TZS'), isNull);
      expect(Money.parseMinor('-1', 'USD'), isNull);
    });
  });
}
