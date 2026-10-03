import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: onTap == null
        ? Padding(padding: padding, child: child)
        : InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});
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

class FinancialSummaryCard extends StatelessWidget {
  const FinancialSummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.change,
    super.key,
  });
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final String? change;

  @override
  Widget build(BuildContext context) => Card(
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
          if (change != null) ...[
            const SizedBox(height: 4),
            Text(
              change!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.mutedText(context),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class AmountInput extends StatelessWidget {
  const AmountInput({
    required this.controller,
    required this.currency,
    required this.label,
    this.validator,
    this.autofocus = false,
    super.key,
  });
  final TextEditingController controller;
  final String currency;
  final String label;
  final FormFieldValidator<String>? validator;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    autofocus: autofocus,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,. ]'))],
    decoration: InputDecoration(
      labelText: label,
      prefixText: '$currency  ',
      prefixIcon: const Icon(Icons.payments_outlined),
    ),
    validator: validator,
  );
}

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    required this.value,
    required this.categories,
    required this.label,
    required this.onChanged,
    super.key,
  });
  final String value;
  final List<(String, String)> categories;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.category_outlined),
    ),
    items: categories
        .map((item) => DropdownMenuItem(value: item.$1, child: Text(item.$2)))
        .toList(),
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: busy ? null : onPressed,
    icon: busy
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon ?? Icons.check),
    label: Text(label),
  );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon ?? Icons.arrow_forward),
    label: Text(label),
  );
}

class LoadingState extends StatelessWidget {
  const LoadingState({this.minimumHeight = 180, super.key});
  final double minimumHeight;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: minimumHeight,
    child: Center(
      child: Semantics(
        label: MaterialLocalizations.of(context).signedInLabel,
        child: const CircularProgressIndicator(),
      ),
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(retryLabel),
          ),
        ],
      ),
    ),
  );
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    required this.title,
    required this.current,
    required this.target,
    required this.progress,
    required this.amountLabel,
    super.key,
  });
  final String title;
  final String current;
  final String target;
  final double progress;
  final String amountLabel;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Semantics(
          label: title,
          value: '${(progress * 100).round()}%',
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0, 1)),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => LinearProgressIndicator(
              value: value,
              minHeight: 9,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$amountLabel: $current / $target',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText(context)),
        ),
      ],
    ),
  );
}
