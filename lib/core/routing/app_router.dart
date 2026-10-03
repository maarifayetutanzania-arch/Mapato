import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/budgets/presentation/budget_screen.dart';
import '../../features/dashboard/presentation/dashboard_screens.dart';
import '../../features/debts/presentation/debt_screen.dart';
import '../../features/finance/domain/finance_models.dart';
import '../../features/onboarding/presentation/onboarding_screens.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/savings/presentation/savings_goal_screens.dart';
import '../../features/settings/presentation/more_screens.dart';
import '../../features/settings/presentation/custom_categories_screen.dart';
import '../../features/transactions/presentation/transaction_screens.dart';
import '../l10n/context_localizations.dart';
import '../providers.dart';
import '../widgets/empty_state.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(authStateProvider, (previous, next) => refresh.refresh());
  ref.listen(profileProvider, (previous, next) => refresh.refresh());
  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final configured = ref.read(firebaseConfiguredProvider);
      final onboardingComplete =
          ref.read(sharedPreferencesProvider).getBool('onboarding_completed') ??
          false;
      final user = ref.read(authStateProvider).asData?.value;

      if (path == '/' || path == '/splash') {
        if (!onboardingComplete) return '/onboarding';
        if (!configured) return '/setup';
        if (ref.read(authStateProvider).isLoading) {
          return '/splash';
        }
        if (user == null) return '/login';
        final profileState = ref.read(profileProvider);
        if (profileState.isLoading) return '/splash';
        final profile = profileState.asData?.value;
        return profile == null || !profile.setupComplete
            ? '/profile/setup'
            : '/home';
      }

      if (!onboardingComplete) {
        return path == '/onboarding' ? null : '/onboarding';
      }
      if (path == '/onboarding') return '/language';
      if (path == '/language') return null;
      if (!configured) return path == '/setup' ? null : '/setup';
      if (path == '/setup') return '/login';

      final publicPaths = {'/login', '/verify'};
      final protected =
          path == '/home' ||
          path == '/transactions' ||
          path == '/budgets' ||
          path == '/goals' ||
          path == '/more' ||
          path.startsWith('/transaction/') ||
          path.startsWith('/goal/') ||
          path == '/profile' ||
          path == '/profile/setup' ||
          path == '/settings' ||
          path.startsWith('/settings/') ||
          path == '/reports' ||
          path == '/debts' ||
          path.startsWith('/information/');
      if (user == null && protected) return '/login';
      if (user != null) {
        final profileState = ref.read(profileProvider);
        if (profileState.isLoading) {
          return path == '/splash' ? null : '/splash';
        }
        final profile = profileState.asData?.value;
        if (profile == null || !profile.setupComplete) {
          return path == '/profile/setup' ? null : '/profile/setup';
        }
        if (path == '/profile/setup' || publicPaths.contains(path)) {
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _SplashScreen()),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const FirebaseSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const EmailLoginScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final email = state.extra;
          return email is String
              ? OtpVerificationScreen(email: email)
              : const _NotFoundScreen();
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/setup',
        builder: (context, state) => const ProfileSetupWizardScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/budgets',
                builder: (context, state) => const BudgetsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/goals',
                builder: (context, state) => const SavingsGoalsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/transaction/new',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/transaction/:transactionId/edit',
        builder: (context, state) {
          final transaction = state.extra;
          return transaction is FinanceTransaction
              ? AddTransactionScreen(transaction: transaction)
              : const _NotFoundScreen();
        },
      ),
      GoRoute(
        path: '/transaction/:transactionId',
        builder: (context, state) {
          final transaction = state.extra;
          return transaction is FinanceTransaction
              ? TransactionDetailScreen(transaction: transaction)
              : const _NotFoundScreen();
        },
      ),
      GoRoute(
        path: '/goal/:goalId/history',
        builder: (context, state) {
          final goal = state.extra;
          return goal is SavingsGoal
              ? GoalHistoryScreen(goal: goal)
              : const _NotFoundScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/settings/categories',
        builder: (context, state) => const CustomCategoriesScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(path: '/debts', builder: (context, state) => const DebtsScreen()),
      GoRoute(
        path: '/information/:kind',
        builder: (context, state) =>
            InformationScreen(kind: state.pathParameters['kind'] ?? 'help'),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class _RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class _SplashScreen extends ConsumerWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 42,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.appTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.appSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(width: 110, child: LinearProgressIndicator()),
        ],
      ),
    ),
  );
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: EmptyState(
      icon: Icons.search_off_outlined,
      title: context.l10n.unknownPageTitle,
      message: context.l10n.unknownPageBody,
      action: FilledButton(
        onPressed: () => context.go('/home'),
        child: Text(context.l10n.backHome),
      ),
    ),
  );
}
