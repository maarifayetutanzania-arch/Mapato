import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/context_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_profile.dart';
import '../../finance/application/finance_providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.more)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
            children: [
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(
                    ref.watch(profileProvider).asData?.value?.displayName ??
                        l10n.profile,
                  ),
                  subtitle: Text(user?.email ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile'),
                ),
              ),
              const SizedBox(height: 18),
              _GroupLabel(label: l10n.settings),
              Card(
                child: Column(
                  children: [
                    _MoreTile(
                      icon: Icons.settings_outlined,
                      title: l10n.settings,
                      onTap: () => context.push('/settings'),
                    ),
                    _MoreTile(
                      icon: Icons.insights_outlined,
                      title: l10n.reports,
                      onTap: () => context.push('/reports'),
                    ),
                    _MoreTile(
                      icon: Icons.handshake_outlined,
                      title: l10n.debts,
                      onTap: () => context.push('/debts'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _GroupLabel(label: l10n.helpSupport),
              Card(
                child: Column(
                  children: [
                    _MoreTile(
                      icon: Icons.help_outline,
                      title: l10n.helpSupport,
                      onTap: () => context.push('/information/help'),
                    ),
                    _MoreTile(
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.privacyPolicy,
                      onTap: () => context.push('/information/privacy'),
                    ),
                    _MoreTile(
                      icon: Icons.description_outlined,
                      title: l10n.terms,
                      onTap: () => context.push('/information/terms'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) => Center(
                  child: Text(
                    l10n.appVersion(snapshot.data?.version ?? '1.0.0'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    _MoreTile(
                      icon: Icons.person_outline,
                      title: l10n.profile,
                      onTap: () => context.push('/profile'),
                    ),
                    _MoreTile(
                      icon: Icons.language,
                      title: l10n.language,
                      trailing: Text(
                        Localizations.localeOf(context).languageCode == 'sw'
                            ? l10n.swahili
                            : l10n.english,
                      ),
                      onTap: () => context.push('/settings/language'),
                    ),
                    _MoreTile(
                      icon: Icons.payments_outlined,
                      title: l10n.currency,
                      trailing: Text(
                        ref.watch(profileProvider).asData?.value?.currency ??
                            'TZS',
                      ),
                      onTap: () => _chooseCurrency(context, ref),
                    ),
                    _MoreTile(
                      icon: Icons.brightness_6_outlined,
                      title: _themeModeLabel(
                        context,
                        ref.watch(themeModeProvider),
                      ),
                      onTap: () => _chooseThemeMode(context, ref),
                    ),
                    const _NotificationSetting(),
                    _MoreTile(
                      icon: Icons.lock_outline,
                      title: l10n.security,
                      onTap: () => context.push('/settings/security'),
                    ),
                    _MoreTile(
                      icon: Icons.category_outlined,
                      title: l10n.categories,
                      onTap: () => context.push('/settings/categories'),
                    ),
                    _MoreTile(
                      icon: Icons.ios_share_outlined,
                      title: l10n.exportData,
                      onTap: () => _exportTransactions(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: _MoreTile(
                  icon: Icons.logout,
                  title: l10n.signOut,
                  titleColor: Theme.of(context).colorScheme.error,
                  onTap: () => _signOut(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.language)),
      body: RadioGroup<String>(
        groupValue: locale.languageCode,
        onChanged: (value) async {
          if (value == null) return;
          await ref.read(localeProvider.notifier).setLanguage(value);
          final profile = ref.read(profileProvider).asData?.value;
          if (profile == null) return;
          await ref
              .read(authRepositoryProvider)
              .saveProfile(_copyProfile(profile, language: value));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(value: 'en', title: Text(l10n.english)),
            RadioListTile<String>(value: 'sw', title: Text(l10n.swahili)),
          ],
        ),
      ),
    );
  }
}

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _SettingsError(onRetry: () => ref.invalidate(profileProvider)),
        data: (value) => value == null
            ? Center(child: Text(l10n.profileRequired))
            : _ProfileEditForm(profile: value),
      ),
    );
  }
}

class _ProfileEditForm extends ConsumerStatefulWidget {
  const _ProfileEditForm({required this.profile});
  final AppProfile profile;
  @override
  ConsumerState<_ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends ConsumerState<_ProfileEditForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.profile.displayName,
  );
  late final TextEditingController _income = TextEditingController(
    text: Money.decimalInput(
      widget.profile.monthlyIncomeMinor,
      widget.profile.currency,
    ),
  );
  late final TextEditingController _budget = TextEditingController(
    text: widget.profile.monthlyBudgetMinor == 0
        ? ''
        : Money.decimalInput(
            widget.profile.monthlyBudgetMinor,
            widget.profile.currency,
          ),
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _income.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = Money.parseMinor(_income.text, widget.profile.currency);
    final budgetText = _budget.text.trim();
    final budget = budgetText.isEmpty
        ? 0
        : Money.parseMinor(budgetText, widget.profile.currency);
    if (_name.text.trim().isEmpty || amount == null || budget == null) {
      setState(() => _error = context.l10n.genericError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .saveProfile(
            _copyProfile(
              widget.profile,
              displayName: _name.text.trim(),
              monthlyIncomeMinor: amount,
              monthlyBudgetMinor: budget,
            ),
          );
      ref.invalidate(profileProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.profileSaved)));
      }
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.genericError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextFormField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fullName),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _income,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.monthlyIncome,
            prefixText: '${widget.profile.currency}  ',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _budget,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.monthlyBudget,
            prefixText: '${widget.profile.currency}  ',
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 22),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}

class _NotificationSetting extends ConsumerStatefulWidget {
  const _NotificationSetting();
  @override
  ConsumerState<_NotificationSetting> createState() =>
      _NotificationSettingState();
}

class _NotificationSettingState extends ConsumerState<_NotificationSetting> {
  bool _enabled = true;
  @override
  void initState() {
    super.initState();
    _enabled =
        ref.read(sharedPreferencesProvider).getBool('notifications_enabled') ??
        true;
  }

  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: const Icon(Icons.notifications_outlined),
    title: Text(context.l10n.notifications),
    value: _enabled,
    onChanged: (value) async {
      setState(() => _enabled = value);
      await ref
          .read(sharedPreferencesProvider)
          .setBool('notifications_enabled', value);
    },
  );
}

class InformationScreen extends StatelessWidget {
  const InformationScreen({required this.kind, super.key});
  final String kind;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (kind) {
      'privacy' => l10n.privacyPolicy,
      'terms' => l10n.terms,
      _ => l10n.helpSupport,
    };
    final body = switch (kind) {
      'privacy' => l10n.privacyBody,
      'terms' => l10n.termsBody,
      _ => l10n.helpBody,
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SelectableText(
          body,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.security)),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        context.l10n.securityBody,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ),
  );
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
    child: Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.mutedText(context),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.titleColor,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? titleColor;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title, style: TextStyle(color: titleColor)),
    trailing: trailing ?? const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.onRetry});
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

AppProfile _copyProfile(
  AppProfile profile, {
  String? displayName,
  String? currency,
  String? language,
  int? monthlyIncomeMinor,
  int? monthlyBudgetMinor,
}) => AppProfile(
  displayName: displayName ?? profile.displayName,
  email: profile.email,
  currency: currency ?? profile.currency,
  language: language ?? profile.language,
  monthlyIncomeMinor: monthlyIncomeMinor ?? profile.monthlyIncomeMinor,
  monthlyBudgetMinor: monthlyBudgetMinor ?? profile.monthlyBudgetMinor,
  financialGoal: profile.financialGoal,
  setupComplete: profile.setupComplete,
);

Future<void> _chooseCurrency(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final profile = ref.read(profileProvider).asData?.value;
  if (profile == null) return;
  final currency = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(l10n.currencyTzs),
            onTap: () => Navigator.pop(context, 'TZS'),
          ),
          ListTile(
            title: Text(l10n.currencyUsd),
            onTap: () => Navigator.pop(context, 'USD'),
          ),
          ListTile(
            title: Text(l10n.currencyKes),
            onTap: () => Navigator.pop(context, 'KES'),
          ),
        ],
      ),
    ),
  );
  if (currency == null) return;
  if (!context.mounted) return;
  try {
    await ref
        .read(authRepositoryProvider)
        .saveProfile(_copyProfile(profile, currency: currency));
    ref.invalidate(profileProvider);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }
}

String _themeModeLabel(BuildContext context, ThemeMode mode) => switch (mode) {
  ThemeMode.dark => context.l10n.darkMode,
  ThemeMode.light => context.l10n.lightMode,
  ThemeMode.system => context.l10n.systemMode,
};

Future<void> _chooseThemeMode(BuildContext context, WidgetRef ref) async {
  final selectedMode = ref.read(themeModeProvider);
  final mode = await showDialog<ThemeMode>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.settings),
      content: RadioGroup<ThemeMode>(
        groupValue: selectedMode,
        onChanged: (value) => Navigator.pop(dialogContext, value),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              value: ThemeMode.system,
              title: Text(context.l10n.systemMode),
            ),
            RadioListTile(
              value: ThemeMode.light,
              title: Text(context.l10n.lightMode),
            ),
            RadioListTile(
              value: ThemeMode.dark,
              title: Text(context.l10n.darkMode),
            ),
          ],
        ),
      ),
    ),
  );
  if (!context.mounted || mode == null) return;
  await ref.read(themeModeProvider.notifier).setThemeMode(mode);
}

Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.signOut),
      content: Text(l10n.confirmDeleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.signOut),
        ),
      ],
    ),
  );
  if (confirm != true) return;
  if (!context.mounted) return;
  try {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) {
      context.go('/login');
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }
}

Future<void> _exportTransactions(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  try {
    final transactions = await ref
        .read(financeRepositoryProvider)
        .exportTransactions();
    if (!context.mounted) return;
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportEmpty)));
      return;
    }
    String field(String value) => '"${value.replaceAll('"', '""')}"';
    final rows = <List<String>>[
      ['date', 'type', 'amount', 'currency', 'category', 'description', 'note'],
      for (final item in transactions)
        [
          DateFormat('yyyy-MM-dd').format(item.date),
          item.type.name,
          Money.decimalInput(item.amountMinor, item.currency),
          item.currency,
          item.categoryId,
          item.description,
          item.note,
        ],
    ];
    final csv = rows.map((row) => row.map(field).join(',')).join('\r\n');
    final origin = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(utf8.encode(csv), mimeType: 'text/csv')],
        fileNameOverrides: ['mapato_transactions.csv'],
        subject: l10n.appTitle,
        sharePositionOrigin: origin == null
            ? null
            : origin.localToGlobal(Offset.zero) & origin.size,
        downloadFallbackEnabled: true,
      ),
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
    }
    return;
  }
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.exportReady)));
  }
}
