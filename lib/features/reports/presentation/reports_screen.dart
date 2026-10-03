import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/context_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_labels.dart';
import '../../../core/utils/financial_calculations.dart';
import '../../../core/utils/money.dart';
import '../../auth/application/auth_providers.dart';
import '../../finance/application/finance_providers.dart';
import '../../finance/domain/finance_models.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _months = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency =
        ref.watch(profileProvider).asData?.value?.currency ?? 'TZS';
    final summaries = ref.watch(monthlySummariesProvider);
    final budgets = ref.watch(budgetsProvider);
    final monthSummary = ref.watch(currentMonthSummaryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: summaries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ReportsError(
          onRetry: () => ref.invalidate(monthlySummariesProvider),
        ),
        data: (allMonths) {
          final items = allMonths.take(_months).toList();
          final income = FinancialCalculations.total(
            items.map((item) => (item['incomeMinor'] as num?)?.toInt() ?? 0),
          );
          final expenses = FinancialCalculations.total(
            items.map((item) => (item['expenseMinor'] as num?)?.toInt() ?? 0),
          );
          final cashFlow = income - expenses;
          final rate = FinancialCalculations.savingsRate(
            income: income,
            expenses: expenses,
          );
          final categoryExpenses = <String, int>{};
          final incomeSources = <String, int>{};
          for (final month in items) {
            _mergeAmounts(categoryExpenses, month['expenseByCategory']);
            _mergeAmounts(incomeSources, month['incomeByCategory']);
          }
          final topExpenses = categoryExpenses.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final topIncome = incomeSources.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                children: [
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(value: 1, label: Text(l10n.thisMonth)),
                      ButtonSegment(value: 3, label: Text(l10n.threeMonths)),
                      ButtonSegment(value: 6, label: Text(l10n.sixMonths)),
                      ButtonSegment(value: 12, label: Text(l10n.oneYear)),
                    ],
                    selected: {_months},
                    showSelectedIcon: false,
                    onSelectionChanged: (selected) =>
                        setState(() => _months = selected.first),
                  ),
                  const SizedBox(height: 18),
                  if (items.isEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Text(l10n.noData, textAlign: TextAlign.center),
                      ),
                    ),
                  ] else ...[
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MetricCard(
                          label: l10n.totalIncome,
                          value: Money.formatMinor(income, currency, locale),
                          icon: Icons.south_west,
                          color: AppColors.success,
                        ),
                        _MetricCard(
                          label: l10n.totalExpenses,
                          value: Money.formatMinor(expenses, currency, locale),
                          icon: Icons.north_east,
                          color: AppColors.error,
                        ),
                        _MetricCard(
                          label: l10n.netCashFlow,
                          value: Money.formatMinor(cashFlow, currency, locale),
                          icon: Icons.account_balance_wallet_outlined,
                          color: cashFlow < 0
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                        _MetricCard(
                          label: l10n.savingsRate,
                          value: rate == null
                              ? l10n.noData
                              : '${rate.toStringAsFixed(1)}%',
                          icon: Icons.savings_outlined,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _ReportSection(
                      title: l10n.incomeVsExpenses,
                      child: _CashFlowChart(items: items),
                    ),
                    const SizedBox(height: 16),
                    _ReportSection(
                      title: l10n.topCategories,
                      child: _CategoryBreakdown(
                        items: topExpenses,
                        currency: currency,
                        locale: locale,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ReportSection(
                      title: l10n.incomeSources,
                      child: _CategoryBreakdown(
                        items: topIncome,
                        currency: currency,
                        locale: locale,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ReportSection(
                      title: l10n.budgetPerformance,
                      child: budgets.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stack) => Text(l10n.genericError),
                        data: (items) => monthSummary.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stack) => Text(l10n.genericError),
                          data: (summary) => items.isEmpty
                              ? Text(l10n.noData)
                              : Column(
                                  children: [
                                    for (final budget in items)
                                      _BudgetPerformanceRow(
                                        budget: budget,
                                        spent:
                                            summary.expenseByCategory[budget
                                                .categoryId] ??
                                            0,
                                        currency: currency,
                                        locale: locale,
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _mergeAmounts(Map<String, int> into, Object? raw) {
    if (raw is! Map) return;
    for (final entry in raw.entries) {
      if (entry.value is num) {
        into[entry.key.toString()] =
            (into[entry.key.toString()] ?? 0) + (entry.value as num).toInt();
      }
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.mutedText(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 10),
      Card(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ],
  );
}

class _CashFlowChart extends StatelessWidget {
  const _CashFlowChart({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Text(context.l10n.noData);
    final maximum = items.fold<double>(0, (value, item) {
      final income = (item['incomeMinor'] as num?)?.toDouble() ?? 0;
      final expense = (item['expenseMinor'] as num?)?.toDouble() ?? 0;
      return [value, income, expense].reduce((a, b) => a > b ? a : b);
    });
    if (maximum <= 0) return Text(context.l10n.noData);
    return SizedBox(
      height: 210,
      child: BarChart(
        BarChartData(
          maxY: maximum * 1.15,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            for (var index = 0; index < items.length; index++)
              BarChartGroupData(
                x: index,
                barsSpace: 5,
                barRods: [
                  BarChartRodData(
                    toY:
                        ((items[index]['incomeMinor'] as num?)?.toDouble() ?? 0)
                            .clamp(0, maximum * 1.15),
                    color: AppColors.primary,
                    width: 11,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                  BarChartRodData(
                    toY:
                        ((items[index]['expenseMinor'] as num?)?.toDouble() ??
                                0)
                            .clamp(0, maximum * 1.15),
                    color: AppColors.error,
                    width: 11,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({
    required this.items,
    required this.currency,
    required this.locale,
  });
  final List<MapEntry<String, int>> items;
  final String currency;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Text(context.l10n.noData);
    final maximum = items.first.value;
    return Column(
      children: [
        for (final item in items.take(5)) ...[
          Row(
            children: [
              Expanded(child: Text(categoryLabel(context, item.key))),
              Text(
                Money.formatMinor(item.value, currency, locale),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: maximum <= 0 ? 0 : item.value / maximum,
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _BudgetPerformanceRow extends StatelessWidget {
  const _BudgetPerformanceRow({
    required this.budget,
    required this.spent,
    required this.currency,
    required this.locale,
  });
  final BudgetRecord budget;
  final int spent;
  final String currency;
  final String locale;
  @override
  Widget build(BuildContext context) {
    final progress = FinancialCalculations.budgetProgress(
      spent: spent,
      budget: budget.amountMinor,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(categoryLabel(context, budget.categoryId))),
              Text(
                '${Money.formatMinor(spent, currency, locale)} / ${Money.formatMinor(budget.amountMinor, currency, locale)}',
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            color: progress >= 1
                ? AppColors.error
                : progress >= 0.8
                ? AppColors.warning
                : AppColors.primary,
            minHeight: 7,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }
}

class _ReportsError extends StatelessWidget {
  const _ReportsError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.genericError),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.retry),
        ),
      ],
    ),
  );
}
