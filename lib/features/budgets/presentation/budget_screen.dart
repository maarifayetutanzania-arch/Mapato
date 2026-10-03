import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/context_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_labels.dart';
import '../../../core/utils/financial_calculations.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/application/auth_providers.dart';
import '../../finance/application/finance_providers.dart';
import '../../finance/domain/finance_models.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final budgets = ref.watch(budgetsProvider);
    final summary = ref.watch(currentMonthSummaryProvider);
    final currency =
        ref.watch(profileProvider).asData?.value?.currency ?? 'TZS';
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetTitle),
        actions: [
          IconButton(
            tooltip: l10n.createBudget,
            onPressed: () => _showBudgetForm(context, ref, currency),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: budgets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _BudgetError(onRetry: () => ref.invalidate(budgetsProvider)),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.pie_chart_outline,
                title: l10n.noBudgetsTitle,
                message: l10n.noBudgetsBody,
                action: FilledButton.icon(
                  onPressed: () => _showBudgetForm(context, ref, currency),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createBudget),
                ),
              )
            : summary.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _BudgetError(
                  onRetry: () => ref.invalidate(currentMonthSummaryProvider),
                ),
                data: (totals) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final spent =
                            totals.expenseByCategory[item.categoryId] ?? 0;
                        final remaining = FinancialCalculations.budgetRemaining(
                          budget: item.amountMinor,
                          spent: spent,
                        );
                        final progress = FinancialCalculations.budgetProgress(
                          spent: spent,
                          budget: item.amountMinor,
                        );
                        return _BudgetCard(
                          budget: item,
                          spent: spent,
                          remaining: remaining,
                          progress: progress,
                          currency: currency,
                          locale: locale,
                          onEdit: () => _showBudgetForm(
                            context,
                            ref,
                            currency,
                            budget: item,
                          ),
                          onDelete: () => _deleteBudget(context, ref, item),
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.progress,
    required this.currency,
    required this.locale,
    required this.onEdit,
    required this.onDelete,
  });
  final BudgetRecord budget;
  final int spent;
  final int remaining;
  final double progress;
  final String currency;
  final String locale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = progress >= 1
        ? AppColors.error
        : progress >= 0.8
        ? AppColors.warning
        : AppColors.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(categoryIcon(budget.categoryId), color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          categoryLabel(context, budget.categoryId),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: l10n.edit,
                  onSelected: (value) =>
                      value == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.spent}: ${Money.formatMinor(spent, currency, locale)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${l10n.budgetAmount}: ${Money.formatMinor(budget.amountMinor, currency, locale)}',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Semantics(
              label: categoryLabel(context, budget.categoryId),
              value: '${(progress * 100).round()}%',
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${l10n.remaining}: ${Money.formatMinor(remaining, currency, locale)}',
              style: TextStyle(
                color: remaining < 0
                    ? AppColors.error
                    : AppColors.mutedText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showBudgetForm(
  BuildContext context,
  WidgetRef ref,
  String currency, {
  BudgetRecord? budget,
}) async {
  final l10n = context.l10n;
  final categories = transactionCategories(context, false);
  final amount = TextEditingController(
    text: budget == null
        ? ''
        : Money.decimalInput(budget.amountMinor, currency),
  );
  var categoryId = budget?.categoryId ?? categories.first.$1;
  var loading = false;
  final key = GlobalKey<FormState>();
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(budget == null ? l10n.createBudget : l10n.edit),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: categoryId,
                decoration: InputDecoration(labelText: l10n.category),
                items: categories
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.$1,
                        child: Text(item.$2),
                      ),
                    )
                    .toList(),
                onChanged: budget == null
                    ? (value) =>
                          setDialogState(() => categoryId = value ?? categoryId)
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.budgetAmount,
                  prefixText: '$currency  ',
                ),
                validator: (value) {
                  final parsed = value == null
                      ? null
                      : Money.parseMinor(value, currency);
                  return parsed != null && parsed > 0
                      ? null
                      : l10n.amountInvalid;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: loading
                ? null
                : () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: loading
                ? null
                : () async {
                    if (!key.currentState!.validate()) return;
                    setDialogState(() => loading = true);
                    final now = DateTime.now();
                    try {
                      await ref
                          .read(financeRepositoryProvider)
                          .saveBudget(
                            id: budget?.id ?? '',
                            categoryId: categoryId,
                            amountMinor: Money.parseMinor(
                              amount.text,
                              currency,
                            )!,
                            currency: currency,
                            monthKey:
                                budget?.monthKey ??
                                '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}',
                          );
                      ref.invalidate(budgetsProvider);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } catch (_) {
                      if (!dialogContext.mounted) return;
                      setDialogState(() => loading = false);
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(l10n.genericError)),
                      );
                    }
                  },
            child: loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
    ),
  );
  amount.dispose();
  if (result == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.budgetSaved)));
  }
}

Future<void> _deleteBudget(
  BuildContext context,
  WidgetRef ref,
  BudgetRecord budget,
) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.confirmDeleteTitle),
      content: Text(l10n.confirmDeleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.read(financeRepositoryProvider).deleteBudget(budget.id);
    ref.invalidate(budgetsProvider);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }
}

class _BudgetError extends StatelessWidget {
  const _BudgetError({required this.onRetry});
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
