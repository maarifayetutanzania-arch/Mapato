import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/context_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../finance/application/finance_providers.dart';
import '../../finance/domain/finance_models.dart';

class CustomCategoriesScreen extends ConsumerWidget {
  const CustomCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categories = ref.watch(customCategoriesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        actions: [
          IconButton(
            tooltip: l10n.createCategory,
            onPressed: () => _showCategoryForm(context, ref),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _CategoryError(
          onRetry: () => ref.invalidate(customCategoriesProvider),
        ),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.category_outlined,
                title: l10n.categories,
                message: l10n.noData,
                action: FilledButton.icon(
                  onPressed: () => _showCategoryForm(context, ref),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createCategory),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final category = items[index];
                  final income = category.type == TransactionType.income;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        income ? Icons.south_west : Icons.north_east,
                        color: income ? AppColors.success : AppColors.primary,
                      ),
                      title: Text(category.name),
                      subtitle: Text(
                        income ? l10n.categoryIncome : l10n.categoryExpense,
                      ),
                      trailing: IconButton(
                        tooltip: l10n.delete,
                        onPressed: () =>
                            _deleteCategory(context, ref, category),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.createCategory,
        onPressed: () => _showCategoryForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> _showCategoryForm(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final name = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var type = TransactionType.expense;
  var saving = false;
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(l10n.createCategory),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(l10n.categoryExpense),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(l10n.categoryIncome),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (value) =>
                    setDialogState(() => type = value.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: name,
                maxLength: 32,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.customCategory),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.nameRequired
                    : null,
              ),
            ],
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
                          .saveCategory(id: '', name: name.text, type: type);
                      ref.invalidate(customCategoriesProvider);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } catch (error) {
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
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.categorySaved)));
  }
}

Future<void> _deleteCategory(
  BuildContext context,
  WidgetRef ref,
  CustomCategory category,
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
  if (confirmed != true || !context.mounted) return;
  try {
    await ref.read(financeRepositoryProvider).deleteCategory(category.id);
    ref.invalidate(customCategoriesProvider);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }
}

class _CategoryError extends StatelessWidget {
  const _CategoryError({required this.onRetry});
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
