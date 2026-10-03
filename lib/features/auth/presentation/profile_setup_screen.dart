import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/context_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money.dart';
import '../../finance/application/finance_providers.dart';
import '../application/auth_providers.dart';
import '../data/auth_repository.dart';
import '../domain/app_profile.dart';

class ProfileSetupWizardScreen extends ConsumerStatefulWidget {
  const ProfileSetupWizardScreen({super.key});

  @override
  ConsumerState<ProfileSetupWizardScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupWizardScreen> {
  final _pageController = PageController();
  final _profileFormKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _income = TextEditingController();
  final _budget = TextEditingController();
  final _goalName = TextEditingController();
  final _goalTarget = TextEditingController();
  int _page = 0;
  String _currency = 'TZS';
  String? _financialGoal;
  bool _saving = false;
  String? _error;
  AppProfile? _profile;

  @override
  void initState() {
    super.initState();
    _profile = ref.read(profileProvider).asData?.value;
    final profile = _profile;
    if (profile != null) {
      _name.text = profile.displayName;
      _currency = profile.currency;
      _income.text = Money.decimalInput(
        profile.monthlyIncomeMinor,
        profile.currency,
      );
      _budget.text = profile.monthlyBudgetMinor == 0
          ? ''
          : Money.decimalInput(profile.monthlyBudgetMinor, profile.currency);
      _financialGoal = profile.financialGoal.isEmpty
          ? null
          : profile.financialGoal;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _name.dispose();
    _income.dispose();
    _budget.dispose();
    _goalName.dispose();
    _goalTarget.dispose();
    super.dispose();
  }

  String _goalLabel(String goal) {
    final l10n = context.l10n;
    return switch (goal) {
      'emergency' => l10n.goalEmergency,
      'debt' => l10n.goalDebt,
      'home' => l10n.goalHome,
      'business' => l10n.goalBusiness,
      _ => l10n.goalOther,
    };
  }

  String _title() {
    final l10n = context.l10n;
    return switch (_page) {
      0 => l10n.setupWelcomeTitle,
      1 => l10n.setupProfileTitle,
      2 => l10n.setupBudgetTitle,
      _ => l10n.setupSavingsTitle,
    };
  }

  Future<void> _moveTo(int page) async {
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
    if (mounted) setState(() => _page = page);
  }

  Future<void> _continue() async {
    if (_page == 0) {
      await _moveTo(1);
      return;
    }
    if (_page == 1) {
      if (!_profileFormKey.currentState!.validate()) return;
      final saved = await _savePartialProfile();
      if (saved && mounted) await _moveTo(2);
      return;
    }
    if (_page == 2) {
      final budgetText = _budget.text.trim();
      final amount = budgetText.isEmpty
          ? 0
          : Money.parseMinor(budgetText, _currency);
      if (budgetText.isNotEmpty && (amount == null || amount <= 0)) {
        setState(() => _error = context.l10n.budgetInvalid);
        return;
      }
      if (amount != null && amount > 0) {
        final saved = await _savePartialProfile(monthlyBudgetMinor: amount);
        if (!saved) return;
      }
      await _moveTo(3);
      return;
    }
    await _finishSetup(includeGoal: true);
  }

  Future<void> _skipCurrentStep() async {
    if (_page == 0) {
      await _moveTo(1);
    } else if (_page == 2) {
      await _moveTo(3);
    } else if (_page == 3) {
      await _finishSetup(includeGoal: false);
    }
  }

  Future<bool> _savePartialProfile({int? monthlyBudgetMinor}) =>
      _persistProfile(
        monthlyBudgetMinor:
            monthlyBudgetMinor ?? _profile?.monthlyBudgetMinor ?? 0,
        setupComplete: false,
      );

  Future<void> _finishSetup({required bool includeGoal}) async {
    final name = _goalName.text.trim();
    final targetText = _goalTarget.text.trim();
    final target = targetText.isEmpty
        ? null
        : Money.parseMinor(targetText, _currency);
    if (includeGoal && (name.isNotEmpty || targetText.isNotEmpty)) {
      if (name.isEmpty || target == null || target <= 0) {
        setState(() => _error = context.l10n.goalOptionalHint);
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (includeGoal && name.isNotEmpty && target != null) {
        await ref
            .read(financeRepositoryProvider)
            .saveGoal(
              id: 'onboarding_first_goal',
              name: name,
              targetMinor: target,
              currentMinor: 0,
              currency: _currency,
            );
      }
      final saved = await _persistProfile(
        monthlyBudgetMinor: _profile?.monthlyBudgetMinor ?? 0,
        setupComplete: true,
      );
      if (!saved) return;
      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.genericError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _persistProfile({
    required int monthlyBudgetMinor,
    required bool setupComplete,
  }) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw const AuthInputException('not-authenticated');
      final profile = AppProfile(
        displayName: _name.text.trim(),
        email: user.email ?? _profile?.email ?? '',
        currency: _currency,
        language: Localizations.localeOf(context).languageCode,
        monthlyIncomeMinor: Money.parseMinor(_income.text, _currency) ?? 0,
        financialGoal: _financialGoal ?? '',
        monthlyBudgetMinor: monthlyBudgetMinor,
        setupComplete: setupComplete,
      );
      await ref.read(authRepositoryProvider).saveProfile(profile);
      _profile = profile;
      return true;
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.genericError);
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _profileFields(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _profileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.fullName,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.nameRequired
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: InputDecoration(labelText: l10n.currency),
            items: [
              DropdownMenuItem(value: 'TZS', child: Text(l10n.currencyTzs)),
              DropdownMenuItem(value: 'USD', child: Text(l10n.currencyUsd)),
              DropdownMenuItem(value: 'KES', child: Text(l10n.currencyKes)),
            ],
            onChanged: (value) => setState(() => _currency = value ?? 'TZS'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _income,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.monthlyIncome,
              prefixText: '$_currency  ',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.incomeInvalid;
              }
              return Money.parseMinor(value, _currency) == null
                  ? l10n.incomeInvalid
                  : null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _financialGoal,
            decoration: InputDecoration(labelText: l10n.financialGoal),
            items: ['emergency', 'debt', 'home', 'business', 'other']
                .map(
                  (goal) => DropdownMenuItem(
                    value: goal,
                    child: Text(_goalLabel(goal)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _financialGoal = value),
            validator: (value) => value == null ? l10n.chooseGoal : null,
          ),
        ],
      ),
    );
  }

  Widget _optionalFields(BuildContext context) {
    final l10n = context.l10n;
    if (_page == 2) {
      return TextFormField(
        controller: _budget,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: l10n.monthlyBudget,
          prefixText: '$_currency  ',
          prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.goalOptionalHint,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText(context)),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _goalName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.goalName,
            prefixIcon: const Icon(Icons.savings_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _goalTarget,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.targetAmount,
            prefixText: '$_currency  ',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totalSteps = 4;
    final canSkip = _page == 0 || _page == 2 || _page == 3;
    final actionLabel = _page == 3
        ? l10n.setupFinish
        : _page == 1 || _page == 2
        ? l10n.continueLabel
        : l10n.continueLabel;
    return Scaffold(
      appBar: AppBar(
        leading: _page == 0
            ? null
            : IconButton(
                onPressed: _saving ? null : () => _moveTo(_page - 1),
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.backHome,
              ),
        actions: [
          if (canSkip)
            TextButton(
              onPressed: _saving ? null : _skipCurrentStep,
              child: Text(l10n.skipForNow),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.setupStep(_page + 1, totalSteps),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    label: _title(),
                    value: '${_page + 1} of $totalSteps',
                    child: LinearProgressIndicator(
                      value: (_page + 1) / totalSteps,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      _title(),
                      key: ValueKey(_page),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) => setState(() => _page = page),
                      children: [
                        _WelcomeStep(body: l10n.setupWelcomeBody),
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 30, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.setupProfileBody,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.mutedText(context),
                                    ),
                              ),
                              const SizedBox(height: 24),
                              _profileFields(context),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 30, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.setupBudgetBody,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.mutedText(context),
                                    ),
                              ),
                              const SizedBox(height: 24),
                              _optionalFields(context),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 30, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.setupSavingsBody,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.mutedText(context),
                                    ),
                              ),
                              const SizedBox(height: 24),
                              _optionalFields(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    onPressed: _saving ? null : _continue,
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(actionLabel),
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

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.body});
  final String body;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Icon(
          Icons.account_balance_wallet_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(height: 26),
      Text(
        body,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText(context)),
      ),
    ],
  );
}
