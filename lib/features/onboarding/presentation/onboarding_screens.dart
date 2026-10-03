import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/context_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    (Icons.account_balance_wallet_outlined, 'onboardingIncomeTitle', 'onboardingIncomeBody'),
    (Icons.payments_outlined, 'onboardingExpenseTitle', 'onboardingExpenseBody'),
    (Icons.savings_outlined, 'onboardingSavingsTitle', 'onboardingSavingsBody'),
    (Icons.insights_outlined, 'onboardingWealthTitle', 'onboardingWealthBody'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await SharedPreferences.getInstance().then((preferences) =>
        preferences.setBool('onboarding_completed', true));
    if (mounted) context.go('/language');
  }

  String _localized(String key) {
    final l10n = context.l10n;
    return switch (key) {
      'onboardingIncomeTitle' => l10n.onboardingIncomeTitle,
      'onboardingIncomeBody' => l10n.onboardingIncomeBody,
      'onboardingExpenseTitle' => l10n.onboardingExpenseTitle,
      'onboardingExpenseBody' => l10n.onboardingExpenseBody,
      'onboardingSavingsTitle' => l10n.onboardingSavingsTitle,
      'onboardingSavingsBody' => l10n.onboardingSavingsBody,
      'onboardingWealthTitle' => l10n.onboardingWealthTitle,
      _ => l10n.onboardingWealthBody,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: _finish, child: Text(l10n.skip)),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _slides.length,
                      onPageChanged: (index) => setState(() => _page = index),
                      itemBuilder: (context, index) {
                        final item = _slides[index];
                        return Semantics(
                          header: true,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 116,
                                height: 116,
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(36),
                                ),
                                child: Icon(item.$1, color: colors.primary, size: 52),
                              ),
                              const SizedBox(height: 36),
                              Text(
                                _localized(item.$2),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _localized(item.$3),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == _page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == _page ? colors.primary : colors.outlineVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _page == _slides.length - 1
                        ? _finish
                        : () => _controller.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut),
                    child: Text(_page == _slides.length - 1 ? l10n.getStarted : l10n.next),
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

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  late String _selected = Localizations.localeOf(context).languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RadioGroup<String>(
                  groupValue: _selected,
                  onChanged: (value) {
                    if (value != null) setState(() => _selected = value);
                  },
                  child: Column(
                    children: [
                      RadioListTile<String>(value: 'en', title: Text(l10n.english)),
                      RadioListTile<String>(value: 'sw', title: Text(l10n.swahili)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    final preferences = await SharedPreferences.getInstance();
                    await preferences.setString('preferred_language', _selected);
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                  child: Text(l10n.continueLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
