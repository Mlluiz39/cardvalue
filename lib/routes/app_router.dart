import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/cards/presentation/card_list_screen.dart';
import '../features/cards/presentation/card_form_screen.dart';
import '../features/cards/presentation/card_detail_screen.dart';
import '../features/installments/presentation/purchase_detail_screen.dart';
import '../features/installments/presentation/purchase_form_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/invoices/presentation/reconciliation_screen.dart';
import '../features/invoices/presentation/invoice_list_screen.dart';
import '../features/transactions/presentation/transaction_list_screen.dart';
import '../features/transactions/presentation/transaction_form_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/debts/presentation/debt_list_screen.dart';
import '../features/debts/presentation/debt_form_screen.dart';
import '../features/debts/presentation/debt_detail_screen.dart';
import '../features/goals/presentation/goal_list_screen.dart';
import '../features/goals/presentation/goal_form_screen.dart';
import '../features/goals/presentation/goal_detail_screen.dart';
import '../features/ai/presentation/insights_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/category_management_screen.dart';
import '../features/settings/presentation/tag_management_screen.dart';

final _navigatorKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter router(WidgetRef ref) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    return GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: '/dashboard',
      redirect: (context, state) {
        final loggedIn = isAuth;
        final loggingIn = state.matchedLocation == '/login';
        if (!loggedIn && !loggingIn) return '/login';
        if (loggedIn && loggingIn) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellKey,
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (_, __) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/cards',
              builder: (_, __) => const CardListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, __) => const CardFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => CardDetailScreen(cardId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => CardFormScreen(cardId: state.pathParameters['id']),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/transactions',
              builder: (_, __) => const TransactionListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, __) => const TransactionFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => TransactionDetailScreen(transactionId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => TransactionFormScreen(transactionId: state.pathParameters['id']),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/calendar',
              builder: (_, __) => const CalendarScreen(),
            ),
            GoRoute(
              path: '/reports',
              builder: (_, __) => const ReportsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/purchases/new',
          builder: (_, __) => const PurchaseFormScreen(),
        ),
        GoRoute(
          path: '/purchases/:id',
          builder: (_, state) => PurchaseDetailScreen(purchaseId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/invoices/:id',
          builder: (_, state) => InvoiceListScreen(cardId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'reconciliation',
              builder: (_, state) => ReconciliationScreen(invoiceId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/goals',
          builder: (_, __) => const GoalListScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, __) => const GoalFormScreen()),
            GoRoute(path: ':id', builder: (_, state) => GoalDetailScreen(goalId: state.pathParameters['id']!)),
          ],
        ),
        GoRoute(
          path: '/debts',
          builder: (_, __) => const DebtListScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, __) => const DebtFormScreen()),
            GoRoute(path: ':id', builder: (_, state) => DebtDetailScreen(debtId: state.pathParameters['id']!)),
          ],
        ),
        GoRoute(
          path: '/ai/insights',
          builder: (_, __) => const InsightsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen(),
          routes: [
            GoRoute(path: 'profile', builder: (_, __) => const PlaceholderWidget('Perfil')),
            GoRoute(path: 'categories', builder: (_, __) => const CategoryManagementScreen()),
            GoRoute(path: 'tags', builder: (_, __) => const TagManagementScreen()),
            GoRoute(path: 'notifications', builder: (_, __) => const PlaceholderWidget('Notificações')),
            GoRoute(path: 'appearance', builder: (_, __) => const PlaceholderWidget('Aparência')),
          ],
        ),
      ],
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String label;

  const PlaceholderWidget(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text(label, style: Theme.of(context).textTheme.headlineMedium)),
    );
  }
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _routes = [
    '/dashboard',
    '/cards',
    '/transactions',
    '/calendar',
    '/reports',
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _selectedIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_routes[i]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.credit_card), label: 'Cartões'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Transações'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendário'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Relatórios'),
        ],
      ),
    );
  }
}
