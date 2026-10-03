import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/context_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/financial_calculations.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/application/auth_providers.dart';
import '../../finance/application/finance_providers.dart';
import '../../finance/domain/finance_models.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency =
        ref.watch(profileProvider).asData?.value?.currency ?? 'TZS';
    final goals = ref.watch(savingsGoalsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.goalTitle),
        actions: [
          IconButton(
            tooltip: l10n.createGoal,
            onPressed: () => _showGoalForm(context, ref, currency),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _GoalError(onRetry: () => ref.invalidate(savingsGoalsProvider)),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.savings_outlined,
                title: l10n.noGoalsTitle,
                message: l10n.noGoalsBody,
                action: FilledButton.icon(
                  onPressed: () => _showGoalForm(context, ref, currency),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createGoal),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 112),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _GoalCard(
                      goal: items[index],
                      currency: currency,
                      locale: locale,
                      onEdit: () => _showGoalForm(
                        context,
                        ref,
                        currency,
                        goal: items[index],
                      ),
                      onDelete: () => _deleteGoal(context, ref, items[index]),
                      onChange: (delta) => _changeGoalAmount(
                        context,
                        ref,
                        items[index],
                        delta,
                        currency,
                      ),
                      onHistory: () => context.push(
                        '/goal/${items[index].id}/history',
                        extra: items[index],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.currency,
    required this.locale,
    required this.onEdit,
    required this.onDelete,
    required this.onChange,
    required this.onHistory,
  });
  final SavingsGoal goal;
  final String currency;
  final String locale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<int> onChange;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = FinancialCalculations.goalProgress(
      current: goal.currentMinor,
      target: goal.targetMinor,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: l10n.edit,
                  onSelected: (action) => switch (action) {
                    'edit' => onEdit(),
                    'delete' => onDelete(),
                    _ => onHistory(),
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    PopupMenuItem(
                      value: 'history',
                      child: Text(l10n.goalHistory),
                    ),
                    PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                  ],
                ),
              ],
            ),
            if (goal.targetDate != null)
              Text(
                '${l10n.targetDate}: ${DateFormat.yMMMd(locale).format(goal.targetDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText(context),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${Money.formatMinor(goal.currentMinor, currency, locale)} / ${Money.formatMinor(goal.targetMinor, currency, locale)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Semantics(
              label: goal.name,
              value: '${(progress * 100).round()}%',
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                OutlinedButton.icon(
                  onPressed: () => onChange(1),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addMoney),
                ),
                OutlinedButton.icon(
                  onPressed: () => onChange(-1),
                  icon: const Icon(Icons.remove, size: 18),
                  label: Text(l10n.withdraw),
                ),
                IconButton(
                  tooltip: l10n.goalHistory,
                  onPressed: onHistory,
                  icon: const Icon(Icons.history),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showGoalForm(
  BuildContext context,
  WidgetRef ref,
  String currency, {
  SavingsGoal? goal,
}) async {
  final l10n = context.l10n;
  final name = TextEditingController(text: goal?.name ?? '');
  final target = TextEditingController(
    text: goal == null ? '' : Money.decimalInput(goal.targetMinor, currency),
  );
  final current = TextEditingController(
    text: goal == null ? '0' : Money.decimalInput(goal.currentMinor, currency),
  );
  final formKey = GlobalKey<FormState>();
  DateTime? targetDate = goal?.targetDate;
  var saving = false;
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(goal == null ? l10n.createGoal : l10n.edit),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l10n.goalName),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.nameRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: target,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.targetAmount,
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: current,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.currentAmount,
                    prefixText: '$currency  ',
                  ),
                  validator: (value) {
                    final parsed = value == null
                        ? null
                        : Money.parseMinor(value, currency);
                    final max = Money.parseMinor(target.text, currency) ?? 0;
                    return parsed != null && parsed >= 0 && parsed <= max
                        ? null
                        : l10n.amountInvalid;
                  },
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: targetDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 20),
                      ),
                    );
                    if (context.mounted && picked != null) {
                      setDialogState(() => targetDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    targetDate == null
                        ? l10n.targetDate
                        : '${l10n.targetDate}: ${MaterialLocalizations.of(context).formatMediumDate(targetDate!)}',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving
                ? null
                : () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      await ref
                          .read(financeRepositoryProvider)
                          .saveGoal(
                            id: goal?.id ?? '',
                            name: name.text,
                            targetMinor: Money.parseMinor(
                              target.text,
                              currency,
                            )!,
                            currentMinor: Money.parseMinor(
                              current.text,
                              currency,
                            )!,
                            currency: currency,
                            targetDate: targetDate,
                          );
                      ref.invalidate(savingsGoalsProvider);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } catch (_) {
                      if (!dialogContext.mounted) return;
                      setDialogState(() => saving = false);
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(l10n.genericError)),
                      );
                    }
                  },
            child: saving
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
  name.dispose();
  target.dispose();
  current.dispose();
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.goalSaved)));
  }
}

Future<void> _changeGoalAmount(
  BuildContext context,
  WidgetRef ref,
  SavingsGoal goal,
  int direction,
  String currency,
) async {
  final l10n = context.l10n;
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final amount = await showDialog<int>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(direction > 0 ? l10n.addMoney : l10n.withdraw),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.amount,
            prefixText: '$currency  ',
          ),
          validator: (value) {
            final parsed = value == null
                ? null
                : Money.parseMinor(value, currency);
            return parsed != null && parsed > 0 ? null : l10n.amountInvalid;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(
                dialogContext,
                Money.parseMinor(amountController.text, currency),
              );
            }
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  amountController.dispose();
  if (amount == null) return;
  try {
    await ref
        .read(financeRepositoryProvider)
        .updateGoalAmount(goal.id, amount * direction);
    ref.invalidate(savingsGoalsProvider);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }
}

Future<void> _deleteGoal(
  BuildContext context,
  WidgetRef ref,
  SavingsGoal goal,
) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.confirmDeleteTitle),
      content: Text(l10n.confirmDeleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.read(financeRepositoryProvider).deleteGoal(goal.id);
    ref.invalidate(savingsGoalsProvider);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }
}

class GoalHistoryScreen extends ConsumerWidget {
  const GoalHistoryScreen({required this.goal, super.key});
  final SavingsGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency =
        ref.watch(profileProvider).asData?.value?.currency ?? goal.currency;
    final history = ref
        .watch(financeRepositoryProvider)
        .watchGoalHistory(goal.id);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalHistory)),
      body: StreamBuilder<List<GoalHistoryEntry>>(
        stream: history,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text(l10n.genericError));
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) return Center(child: Text(l10n.noData));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = items[index];
              final date = entry.date == null
                  ? ''
                  : DateFormat.yMMMd(locale).format(entry.date!);
              return ListTile(
                leading: Icon(
                  entry.deltaMinor >= 0
                      ? Icons.add_circle_outline
                      : Icons.remove_circle_outline,
                  color: entry.deltaMinor >= 0
                      ? AppColors.success
                      : AppColors.warning,
                ),
                title: Text(
                  '${entry.deltaMinor >= 0 ? '+' : '−'}${Money.formatMinor(entry.deltaMinor.abs(), currency, locale)}',
                ),
                subtitle: Text(date),
              );
            },
          );
        },
      ),
    );
  }
}

class _GoalError extends StatelessWidget {
  const _GoalError({required this.onRetry});
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
