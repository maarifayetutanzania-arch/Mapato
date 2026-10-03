import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/connectivity_provider.dart';
import '../../../core/l10n/context_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/financial_calculations.dart';
import '../../../core/utils/category_labels.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/application/auth_providers.dart';
import '../../finance/application/finance_providers.dart';
import '../../finance/domain/finance_models.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transaction/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addTransaction),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.transactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline),
            selectedIcon: const Icon(Icons.pie_chart),
            label: l10n.budgets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.savings_outlined),
            selectedIcon: const Icon(Icons.savings),
            label: l10n.goals,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: l10n.more,
          ),
        ],
      ),
    );
  }
}

class DashboardHomeScreen extends ConsumerWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final profile = ref.watch(profileProvider).asData?.value;
    final connectivity = ref.watch(connectivityProvider).asData?.value;
    final balance = ref.watch(lifetimeSummaryProvider);
    final month = ref.watch(currentMonthSummaryProvider);
    final recent = ref.watch(recentTransactionsProvider);
    final summaries = ref.watch(monthlySummariesProvider);
    final currency = profile?.currency ?? 'TZS';
    final now = DateTime.now();
    final time = now.hour < 12
        ? l10n.goodMorning
        : now.hour < 17
        ? l10n.goodAfternoon
        : l10n.goodEvening;
    final firstName = profile?.displayName.split(' ').first ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeGreeting(time, firstName)),
        actions: [
          IconButton(
            tooltip: l10n.notifications,
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 112),
              children: [
                if (connectivity == false)
                  _OfflineNotice(message: l10n.offline),
                const SizedBox(height: 14),
                balance.when(
                  loading: () => const _LoadingCard(height: 172),
                  error: (error, stack) => _RetryCard(
                    onRetry: () => ref.invalidate(lifetimeSummaryProvider),
                    message: l10n.genericError,
                  ),
                  data: (summary) => _BalanceCard(
                    title: l10n.currentBalance,
                    amount: Money.formatMinor(
                      summary.balanceMinor,
                      currency,
                      locale,
                    ),
                    budgetLabel: l10n.monthlyBudget,
                    monthlyBudget: Money.formatMinor(
                      profile?.monthlyBudgetMinor ?? 0,
                      currency,
                      locale,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                month.when(
                  loading: () => const SizedBox(
                    height: 104,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => _RetryCard(
                    onRetry: () => ref.invalidate(currentMonthSummaryProvider),
                    message: l10n.genericError,
                  ),
                  data: (summary) => LayoutBuilder(
                    builder: (context, constraints) {
                      final width = (constraints.maxWidth - 24) / 3;
                      final savings = FinancialCalculations.savings(
                        income: summary.incomeMinor,
                        expenses: summary.expenseMinor,
                      );
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _SummaryCard(
                            width: width,
                            icon: Icons.south_west,
                            label: l10n.income,
                            amount: Money.formatMinor(
                              summary.incomeMinor,
                              currency,
                              locale,
                            ),
                            color: AppColors.success,
                          ),
                          _SummaryCard(
                            width: width,
                            icon: Icons.north_east,
                            label: l10n.expenses,
                            amount: Money.formatMinor(
                              summary.expenseMinor,
                              currency,
                              locale,
                            ),
                            color: AppColors.error,
                          ),
                          _SummaryCard(
                            width: width,
                            icon: Icons.savings_outlined,
                            label: l10n.savings,
                            amount: Money.formatMinor(
                              savings,
                              currency,
                              locale,
                            ),
                            color: AppColors.primary,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                _SectionHeading(title: l10n.incomeVsExpenses),
                const SizedBox(height: 12),
                summaries.when(
                  loading: () => const _LoadingCard(height: 220),
                  error: (error, stack) => _RetryCard(
                    onRetry: () => ref.invalidate(monthlySummariesProvider),
                    message: l10n.genericError,
                  ),
                  data: (items) => _MonthlyChart(
                    items: items,
                    currency: currency,
                    locale: locale,
                  ),
                ),
                const SizedBox(height: 26),
                _SectionHeading(
                  title: l10n.recentTransactions,
                  trailing: TextButton(
                    onPressed: () => context.go('/transactions'),
                    child: Text(l10n.viewAll),
                  ),
                ),
                const SizedBox(height: 8),
                recent.when(
                  loading: () => const _LoadingCard(height: 150),
                  error: (error, stack) => _RetryCard(
                    onRetry: () => ref.invalidate(recentTransactionsProvider),
                    message: l10n.genericError,
                  ),
                  data: (items) => items.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: l10n.noTransactionsTitle,
                          message: l10n.noTransactionsBody,
                          action: FilledButton.icon(
                            onPressed: () => context.push('/transaction/new'),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addTransaction),
                          ),
                        )
                      : Card(
                          child: Column(
                            children: [
                              for (final item in items)
                                _TransactionRow(
                                  transaction: item,
                                  currency: currency,
                                  locale: locale,
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.budgetLabel,
    required this.monthlyBudget,
  });
  final String title;
  final String amount;
  final String budgetLabel;
  final String monthlyBudget;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 17,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  budgetLabel,
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    monthlyBudget,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });
  final double width;
  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.mutedText(context),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({
    required this.items,
    required this.currency,
    required this.locale,
  });
  final List<Map<String, dynamic>> items;
  final String currency;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Text(l10n.noData, textAlign: TextAlign.center),
        ),
      );
    }
    final values = items.reversed.take(6).toList();
    final maximum = values.fold<double>(0, (maxValue, item) {
      final income = (item['incomeMinor'] as num?)?.toDouble() ?? 0;
      final expense = (item['expenseMinor'] as num?)?.toDouble() ?? 0;
      return [maxValue, income, expense].reduce((a, b) => a > b ? a : b);
    });
    if (maximum == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Text(l10n.noData, textAlign: TextAlign.center),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 18, 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(color: AppColors.primary, label: l10n.income),
                const SizedBox(width: 18),
                _Legend(color: AppColors.error, label: l10n.expenses),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 190,
              child: BarChart(
                BarChartData(
                  maxY: maximum * 1.2,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= values.length) {
                            return const SizedBox.shrink();
                          }
                          final key =
                              values[index]['monthKey'] as String? ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              key.length >= 7 ? key.substring(5) : '',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var index = 0; index < values.length; index++)
                      BarChartGroupData(
                        x: index,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(
                            toY:
                                ((values[index]['incomeMinor'] as num?)
                                            ?.toDouble() ??
                                        0)
                                    .clamp(0, maximum * 1.2),
                            color: AppColors.primary,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY:
                                ((values[index]['expenseMinor'] as num?)
                                            ?.toDouble() ??
                                        0)
                                    .clamp(0, maximum * 1.2),
                            color: AppColors.error,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                  ],
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                          BarTooltipItem(
                            Money.formatMinor(
                              rod.toY.toInt(),
                              currency,
                              locale,
                            ),
                            TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onInverseSurface,
                              fontSize: 12,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      ?trailing,
    ],
  );
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off_outlined, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: const Center(child: CircularProgressIndicator()),
  );
}

class _RetryCard extends StatelessWidget {
  const _RetryCard({required this.onRetry, required this.message});
  final VoidCallback onRetry;
  final String message;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retry),
          ),
        ],
      ),
    ),
  );
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.currency,
    required this.locale,
  });
  final FinanceTransaction transaction;
  final String currency;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (isIncome ? AppColors.success : AppColors.primary)
            .withValues(alpha: 0.1),
        child: Icon(
          isIncome ? Icons.south_west : Icons.north_east,
          color: isIncome ? AppColors.success : AppColors.primary,
          size: 19,
        ),
      ),
      title: Text(categoryLabel(context, transaction.categoryId)),
      subtitle: Text(
        '${transaction.description} · ${MaterialLocalizations.of(context).formatMediumDate(transaction.date)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${isIncome ? '+' : '−'}${Money.formatMinor(transaction.amountMinor, currency, locale)}',
        style: TextStyle(
          color: isIncome ? AppColors.success : AppColors.text(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () =>
          context.push('/transaction/${transaction.id}', extra: transaction),
    );
  }
}
