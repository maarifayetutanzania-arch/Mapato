import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/context_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_labels.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/application/auth_providers.dart';
import '../../finance/application/finance_providers.dart';
import '../../finance/domain/finance_models.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _search = TextEditingController();
  String _typeFilter = 'all';
  String? _categoryFilter;
  bool _newestFirst = true;
  DateTimeRange? _dateRange;
  bool _loadingMore = false;
  List<FinanceTransaction> _olderItems = [];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadMore(List<FinanceTransaction> current) async {
    if (_loadingMore || current.isEmpty) return;
    setState(() => _loadingMore = true);
    try {
      final page = await ref
          .read(financeRepositoryProvider)
          .loadTransactionsAfter(current.last.id);
      if (mounted) setState(() => _olderItems = [..._olderItems, ...page]);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _chooseDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (mounted && range != null) setState(() => _dateRange = range);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency =
        ref.watch(profileProvider).asData?.value?.currency ?? 'TZS';
    final transactions = ref.watch(transactionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactions)),
      body: transactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _InlineError(onRetry: () => ref.invalidate(transactionsProvider)),
        data: (firstPage) {
          final source = [...firstPage, ..._olderItems];
          final searchTerm = _search.text.trim().toLowerCase();
          final filtered =
              source.where((transaction) {
                final typeMatches =
                    _typeFilter == 'all' ||
                    transaction.type.name == _typeFilter;
                final categoryMatches =
                    _categoryFilter == null ||
                    transaction.categoryId == _categoryFilter;
                final dateMatches =
                    _dateRange == null ||
                    (!transaction.date.isBefore(_dateRange!.start) &&
                        !transaction.date.isAfter(
                          _dateRange!.end.add(const Duration(days: 1)),
                        ));
                final queryMatches =
                    searchTerm.isEmpty ||
                    transaction.description.toLowerCase().contains(
                      searchTerm,
                    ) ||
                    categoryLabel(
                      context,
                      transaction.categoryId,
                    ).toLowerCase().contains(searchTerm);
                return typeMatches &&
                    categoryMatches &&
                    dateMatches &&
                    queryMatches;
              }).toList()..sort(
                (a, b) => _newestFirst
                    ? b.date.compareTo(a.date)
                    : a.date.compareTo(b.date),
              );
          final groups = <String, List<FinanceTransaction>>{};
          for (final item in filtered) {
            final key = DateFormat.yMMMM(locale).format(item.date);
            groups.putIfAbsent(key, () => []).add(item);
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Column(
                  children: [
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: l10n.search,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _search.clear();
                                  setState(() {});
                                },
                                tooltip: l10n.cancel,
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SegmentedButton<String>(
                            segments: [
                              ButtonSegment(
                                value: 'all',
                                label: Text(l10n.filterAll),
                              ),
                              ButtonSegment(
                                value: 'income',
                                label: Text(l10n.filterIncome),
                              ),
                              ButtonSegment(
                                value: 'expense',
                                label: Text(l10n.filterExpenses),
                              ),
                            ],
                            selected: {_typeFilter},
                            showSelectedIcon: false,
                            onSelectionChanged: (selected) =>
                                setState(() => _typeFilter = selected.first),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: _chooseDateRange,
                            tooltip: l10n.dateFilter,
                            icon: Icon(
                              _dateRange == null
                                  ? Icons.calendar_month_outlined
                                  : Icons.event_available,
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () =>
                                setState(() => _newestFirst = !_newestFirst),
                            tooltip: _newestFirst ? l10n.newest : l10n.oldest,
                            icon: Icon(
                              _newestFirst ? Icons.south : Icons.north,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_dateRange != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ActionChip(
                          avatar: const Icon(Icons.close, size: 16),
                          label: Text(
                            '${MaterialLocalizations.of(context).formatShortDate(_dateRange!.start)} – ${MaterialLocalizations.of(context).formatShortDate(_dateRange!.end)}',
                          ),
                          onPressed: () => setState(() => _dateRange = null),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
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
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                        children: [
                          for (final entry in groups.entries) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: AppColors.mutedText(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            Card(
                              child: Column(
                                children: [
                                  for (final item in entry.value)
                                    _TransactionTile(
                                      transaction: item,
                                      currency: currency,
                                      locale: locale,
                                    ),
                                ],
                              ),
                            ),
                          ],
                          if (firstPage.length == 50)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: _loadingMore
                                    ? const CircularProgressIndicator()
                                    : TextButton.icon(
                                        onPressed: () => _loadMore(firstPage),
                                        icon: const Icon(Icons.expand_more),
                                        label: Text(l10n.viewAll),
                                      ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({this.transaction, super.key});
  final FinanceTransaction? transaction;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late final TextEditingController _note;
  late TransactionType _type;
  late String _category;
  late DateTime _date;
  bool _loading = false;
  String? _error;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _amount = TextEditingController(
      text: transaction == null
          ? ''
          : Money.decimalInput(transaction.amountMinor, transaction.currency),
    );
    _description = TextEditingController(text: transaction?.description ?? '');
    _note = TextEditingController(text: transaction?.note ?? '');
    _type = transaction?.type ?? TransactionType.expense;
    _category = transaction?.categoryId ?? 'food';
    _date = transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (mounted && selected != null) setState(() => _date = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = ref.read(profileProvider).asData?.value;
    final currency = profile?.currency ?? 'TZS';
    final amount = Money.parseMinor(_amount.text, currency);
    if (amount == null || amount <= 0) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(financeRepositoryProvider)
          .saveTransaction(
            FinanceTransaction(
              id: widget.transaction?.id ?? '',
              type: _type,
              amountMinor: amount,
              currency: currency,
              categoryId: _category,
              description: _description.text.trim(),
              date: _date,
              note: _note.text.trim(),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.transactionSaved)));
      context.pop();
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.genericError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency =
        ref.watch(profileProvider).asData?.value?.currency ?? 'TZS';
    final categories = transactionCategories(
      context,
      _type == TransactionType.income,
    );
    if (!categories.any((entry) => entry.$1 == _category)) {
      _category = categories.first.$1;
    }
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.edit : l10n.addTransaction)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.amount,
                      prefixText: '$currency  ',
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.amountRequired;
                      }
                      final parsed = Money.parseMinor(value, currency);
                      return parsed != null && parsed > 0
                          ? null
                          : l10n.amountInvalid;
                    },
                  ),
                  const SizedBox(height: 18),
                  SegmentedButton<TransactionType>(
                    segments: [
                      ButtonSegment(
                        value: TransactionType.expense,
                        icon: const Icon(Icons.north_east),
                        label: Text(l10n.expense),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        icon: const Icon(Icons.south_west),
                        label: Text(l10n.income),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (value) => setState(() {
                      _type = value.first;
                      _category = transactionCategories(
                        context,
                        _type == TransactionType.income,
                      ).first.$1;
                    }),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: l10n.category,
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: categories
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.$1,
                            child: Text(entry.$2),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(
                      () => _category = value ?? categories.first.$1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _description,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.descriptionRequired
                        : null,
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      '${l10n.date}: ${MaterialLocalizations.of(context).formatMediumDate(_date)}',
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _note,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.optionalNote,
                      alignLabelWithHint: true,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({required this.transaction, super.key});
  final FinanceTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency =
        ref.watch(profileProvider).asData?.value?.currency ??
        transaction.currency;
    final isIncome = transaction.type == TransactionType.income;
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryLabel(context, transaction.categoryId)),
        actions: [
          IconButton(
            tooltip: l10n.edit,
            onPressed: () => context.push(
              '/transaction/${transaction.id}/edit',
              extra: transaction,
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: l10n.delete,
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    categoryIcon(transaction.categoryId),
                    size: 34,
                    color: isIncome ? AppColors.success : AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${isIncome ? '+' : '−'}${Money.formatMinor(transaction.amountMinor, currency, locale)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isIncome ? AppColors.success : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _DetailRow(
            label: l10n.type,
            value: isIncome ? l10n.income : l10n.expense,
          ),
          _DetailRow(
            label: l10n.category,
            value: categoryLabel(context, transaction.categoryId),
          ),
          _DetailRow(
            label: l10n.date,
            value: DateFormat.yMMMMd(locale).format(transaction.date),
          ),
          if (transaction.note.isNotEmpty)
            _DetailRow(label: l10n.note, value: transaction.note),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
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
      await ref
          .read(financeRepositoryProvider)
          .deleteTransaction(transaction.id);
      ref.invalidate(transactionsProvider);
      if (context.mounted) {
        context.pop();
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    }
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
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
          categoryIcon(transaction.categoryId),
          color: isIncome ? AppColors.success : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        transaction.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${categoryLabel(context, transaction.categoryId)} · ${MaterialLocalizations.of(context).formatMediumDate(transaction.date)}',
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(flex: 2, child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});
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
