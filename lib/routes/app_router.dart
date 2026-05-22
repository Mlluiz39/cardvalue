import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';

// Dashboard
import '../features/dashboard/presentation/dashboard_screen.dart';

// Cards
import '../features/cards/presentation/card_list_screen.dart';
import '../features/cards/presentation/card_form_screen.dart';
import '../features/cards/presentation/card_detail_screen.dart';

// Transactions
import '../features/transactions/presentation/transaction_list_screen.dart';
import '../features/transactions/presentation/transaction_form_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';

// Calendar
import '../features/calendar/presentation/calendar_screen.dart';

// Reports
import '../features/reports/presentation/reports_screen.dart';

// Purchases
import '../features/installments/presentation/purchase_form_screen.dart';
import '../features/installments/presentation/purchase_detail_screen.dart';

// Invoices
import '../features/invoices/presentation/invoice_list_screen.dart';
import '../features/invoices/presentation/reconciliation_screen.dart';
import '../services/invoice_parser_service.dart';

// Goals
import '../features/goals/presentation/goal_list_screen.dart';
import '../features/goals/presentation/goal_form_screen.dart';
import '../features/goals/presentation/goal_detail_screen.dart';

// Debts
import '../features/debts/presentation/debt_list_screen.dart';
import '../features/debts/presentation/debt_form_screen.dart';
import '../features/debts/presentation/debt_detail_screen.dart';

// AI
import '../features/ai/presentation/insights_screen.dart';

// Settings
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/category_management_screen.dart';
import '../features/settings/presentation/tag_management_screen.dart';

import '../shared/widgets/placeholder_widget.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calcSelectedIndex(context),
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.credit_card_outlined), selectedIcon: Icon(Icons.credit_card), label: 'Cartões'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transações'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendário'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Relatórios'),
        ],
      ),
    );
  }

  int _calcSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/cards')) return 1;
    if (location.startsWith('/transactions')) return 2;
    if (location.startsWith('/calendar')) return 3;
    if (location.startsWith('/reports')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/dashboard');
      case 1: context.go('/cards');
      case 2: context.go('/transactions');
      case 3: context.go('/calendar');
      case 4: context.go('/reports');
    }
  }
}

CustomTransitionPage<T> _buildPageWithTransition<T>({required Widget child, required LocalKey key}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class AppRouter {
  static GoRouter router(WidgetRef ref) {
    final isAuth = ref.watch(isAuthenticatedProvider);

    return GoRouter(
      initialLocation: '/dashboard',
      redirect: (context, state) {
        final isOnboarding = state.matchedLocation == '/onboarding';
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isAuth && !isLoggingIn && !isOnboarding) return '/login';
        if (isAuth && isLoggingIn) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const OnboardingScreen(),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const DashboardScreen(),
              ),
            ),
            GoRoute(
              path: '/cards',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const CardListScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'new',
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    key: state.pageKey,
                    child: const CardFormScreen(),
                  ),
                ),
                GoRoute(
                  path: ':cardId',
                  pageBuilder: (context, state) {
                    final cardId = state.pathParameters['cardId']!;
                    return _buildPageWithTransition(
                      key: state.pageKey,
                      child: CardDetailScreen(cardId: cardId),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      pageBuilder: (context, state) {
                        final cardId = state.pathParameters['cardId']!;
                        return _buildPageWithTransition(
                          key: state.pageKey,
                          child: CardFormScreen(cardId: cardId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/transactions',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const TransactionListScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'new',
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    key: state.pageKey,
                    child: const TransactionFormScreen(),
                  ),
                ),
                GoRoute(
                  path: ':transactionId',
                  pageBuilder: (context, state) {
                    final transactionId = state.pathParameters['transactionId']!;
                    return _buildPageWithTransition(
                      key: state.pageKey,
                      child: TransactionDetailScreen(transactionId: transactionId),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      pageBuilder: (context, state) {
                        final transactionId = state.pathParameters['transactionId']!;
                        return _buildPageWithTransition(
                          key: state.pageKey,
                          child: TransactionFormScreen(transactionId: transactionId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/calendar',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const CalendarScreen(),
              ),
            ),
            GoRoute(
              path: '/reports',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const ReportsScreen(),
              ),
            ),
          ],
        ),
        // Routes outside shell
        GoRoute(
          path: '/purchases/new',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const PurchaseFormScreen(),
          ),
        ),
        GoRoute(
          path: '/purchases/:purchaseId',
          pageBuilder: (context, state) {
            final purchaseId = state.pathParameters['purchaseId']!;
            return _buildPageWithTransition(
              key: state.pageKey,
              child: PurchaseDetailScreen(purchaseId: purchaseId),
            );
          },
        ),
        GoRoute(
          path: '/invoices/:cardId',
          pageBuilder: (context, state) {
            final cardId = state.pathParameters['cardId']!;
            return _buildPageWithTransition(
              key: state.pageKey,
              child: InvoiceListScreen(cardId: cardId),
            );
          },
          routes: [
            GoRoute(
              path: 'reconciliation',
              pageBuilder: (context, state) {
                final cardId = state.pathParameters['cardId']!;
                final items = state.extra as List<InvoiceLineItem>?;
                return _buildPageWithTransition(
                  key: state.pageKey,
                  child: ReconciliationScreen(cardId: cardId, parsedItems: items ?? []),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/goals',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const GoalListScreen(),
          ),
          routes: [
            GoRoute(
              path: 'new',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const GoalFormScreen(),
              ),
            ),
            GoRoute(
              path: ':goalId',
              pageBuilder: (context, state) {
                final goalId = state.pathParameters['goalId']!;
                return _buildPageWithTransition(
                  key: state.pageKey,
                  child: GoalDetailScreen(goalId: goalId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/debts',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const DebtListScreen(),
          ),
          routes: [
            GoRoute(
              path: 'new',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const DebtFormScreen(),
              ),
            ),
            GoRoute(
              path: ':debtId',
              pageBuilder: (context, state) {
                final debtId = state.pathParameters['debtId']!;
                return _buildPageWithTransition(
                  key: state.pageKey,
                  child: DebtDetailScreen(debtId: debtId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/ai/insights',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const InsightsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'profile',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const PlaceholderWidget(label: 'Perfil'),
              ),
            ),
            GoRoute(
              path: 'categories',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const CategoryManagementScreen(),
              ),
            ),
            GoRoute(
              path: 'tags',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const TagManagementScreen(),
              ),
            ),
            GoRoute(
              path: 'notifications',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const PlaceholderWidget(label: 'Notificações'),
              ),
            ),
            GoRoute(
              path: 'appearance',
              pageBuilder: (context, state) => _buildPageWithTransition(
                key: state.pageKey,
                child: const PlaceholderWidget(label: 'Aparência'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
