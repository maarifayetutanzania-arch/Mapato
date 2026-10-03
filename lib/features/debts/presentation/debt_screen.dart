import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/context_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/application/auth_providers.dart';
import '../../finance/application/finance_providers.dart';
import '../../finance/domain/finance_models.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});
  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  DebtDirection? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency =
        ref.watch(profileProvider).asData?.value?.currency ?? 'TZS';
    final debts = ref.watch(debtsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debts),
        actions: [
          IconButton(
            tooltip: l10n.createDebt,
            onPressed: () => _showDebtForm(context, ref, currency),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: debts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _DebtError(onRetry: () => ref.invalidate(debtsProvider)),
        data: (items) {
          final visible = _filter == null
              ? items
              : items.where((debt) => debt.direction == _filter).toList();
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.handshake_outlined,
              title: l10n.debts,
              message: l10n.noData,
              action: FilledButton.icon(
                onPressed: () => _showDebtForm(context, ref, currency),
                icon: const Icon(Icons.add),
                label: Text(l10n.createDebt),
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton<DebtDirection?>(
                  segments: [
                    ButtonSegment(value: null, label: Text(l10n.filterAll)),
                    ButtonSegment(
                      value: DebtDirection.owedByMe,
                      label: Text(l10n.debtOwe),
                    ),
                    ButtonSegment(
                      value: DebtDirection.owedToMe,
                      label: Text(l10n.debtOwedToMe),
                    ),
                  ],
                  selected: {_filter},
                  showSelectedIcon: false,
                  onSelectionChanged: (value) =>
                      setState(() => _filter = value.first),
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? Center(child: Text(l10n.noData))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _DebtCard(
                          debt: visible[index],
                          currency: currency,
                          locale: locale,
                          onEdit: () => _showDebtForm(
                            context,
                            ref,
                            currency,
                            debt: visible[index],
                          ),
                          onDelete: () =>
                              _deleteDebt(context, ref, visible[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({
    required this.debt,
    required this.currency,
    required this.locale,
    required this.onEdit,
    required this.onDelete,
  });
  final DebtRecord debt;
  final String currency;
  final String locale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = debt.amountMinor <= 0
        ? 0.0
        : (debt.paidMinor / debt.amountMinor).clamp(0, 1).toDouble();
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
                    debt.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
            Text(
              '${debt.direction == DebtDirection.owedByMe ? l10n.debtOwe : l10n.debtOwedToMe} · ${debt.person}',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.amount}: ${Money.formatMinor(debt.amountMinor, currency, locale)}',
                  ),
                ),
                Expanded(
                  child: Text(
                    '${l10n.remaining}: ${Money.formatMinor(debt.remainingMinor, currency, locale)}',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Semantics(
              label: debt.name,
              value: '${(progress * 100).round()}%',
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                color: AppColors.secondary,
              ),
            ),
            if (debt.dueDate != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.dueDate}: ${DateFormat.yMMMd(locale).format(debt.dueDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText(context),
                ),
              ),
            ],
            if (debt.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(debt.note),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _showDebtForm(
  BuildContext context,
  WidgetRef ref,
  String currency, {
  DebtRecord? debt,
}) async {
  final l10n = context.l10n;
  final name = TextEditingController(text: debt?.name ?? '');
  final person = TextEditingController(text: debt?.person ?? '');
  final amount = TextEditingController(
    text: debt == null ? '' : Money.decimalInput(debt.amountMinor, currency),
  );
  final paid = TextEditingController(
    text: debt == null ? '0' : Money.decimalInput(debt.paidMinor, currency),
  );
  final note = TextEditingController(text: debt?.note ?? '');
  final formKey = GlobalKey<FormState>();
  var direction = debt?.direction ?? DebtDirection.owedByMe;
  DateTime? dueDate = debt?.dueDate;
  var saving = false;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(debt == null ? l10n.createDebt : l10n.edit),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<DebtDirection>(
                  segments: [
                    ButtonSegment(
                      value: DebtDirection.owedByMe,
                      label: Text(l10n.debtOwe),
                    ),
                    ButtonSegment(
                      value: DebtDirection.owedToMe,
                      label: Text(l10n.debtOwedToMe),
                    ),
                  ],
                  selected: {direction},
                  onSelectionChanged: (value) =>
                      setDialogState(() => direction = value.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(labelText: l10n.debtName),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.nameRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: person,
                  decoration: InputDecoration(labelText: l10n.personCompany),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.amount,
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
                  controller: paid,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.amountPaid,
                    prefixText: '$currency  ',
                  ),
                  validator: (value) {
                    final parsed = value == null
                        ? null
                        : Money.parseMinor(value, currency);
                    final max = Money.parseMinor(amount.text, currency) ?? 0;
                    return parsed != null && parsed >= 0 && parsed <= max
                        ? null
                        : l10n.amountInvalid;
                  },
                ),
                TextButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? now,
                      firstDate: DateTime(now.year - 10),
                      lastDate: DateTime(now.year + 20),
                    );
                    if (context.mounted && picked != null) {
                      setDialogState(() => dueDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    dueDate == null
                        ? l10n.dueDate
                        : '${l10n.dueDate}: ${MaterialLocalizations.of(context).formatMediumDate(dueDate!)}',
                  ),
                ),
                TextFormField(
                  controller: note,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: l10n.note),
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
                          .saveDebt(
                            id: debt?.id ?? '',
                            name: name.text,
                            person: person.text,
                            direction: direction,
                            amountMinor: Money.parseMinor(
                              amount.text,
                              currency,
                            )!,
                            paidMinor: Money.parseMinor(paid.text, currency)!,
                            currency: currency,
                            dueDate: dueDate,
                            note: note.text,
                          );
                      ref.invalidate(debtsProvider);
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
  person.dispose();
  amount.dispose();
  paid.dispose();
  note.dispose();
  if (result == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.debtSaved)));
  }
}

Future<void> _deleteDebt(
  BuildContext context,
  WidgetRef ref,
  DebtRecord debt,
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
    await ref.read(financeRepositoryProvider).deleteDebt(debt.id);
    ref.invalidate(debtsProvider);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }
}

class _DebtError extends StatelessWidget {
  const _DebtError({required this.onRetry});
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
