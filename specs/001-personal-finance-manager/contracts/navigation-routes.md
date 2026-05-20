# Navigation Routes (GoRouter)

## Route Tree

```
/auth                          → AuthShell (no bottom nav)
  /auth/login                  → LoginScreen
  /auth/register               → RegisterScreen
  /auth/forgot-password        → ForgotPasswordScreen

/                              → MainShell (bottom nav)
  /dashboard                   → DashboardScreen (tab 0)
  /cards                       → CardsScreen (tab 1)
    /cards/:id                 → CardDetailScreen
    /cards/new                 → CardFormScreen
    /cards/:id/edit            → CardFormScreen (edit mode)
  /transactions                → TransactionsScreen (tab 2)
    /transactions/new          → TransactionFormScreen
    /transactions/:id          → TransactionDetailScreen
    /transactions/:id/edit     → TransactionFormScreen (edit mode)
  /calendar                    → CalendarScreen (tab 3)
  /reports                     → ReportsScreen (tab 4)

/settings                      → SettingsScreen
  /settings/profile            → ProfileScreen
  /settings/categories         → CategoryManagementScreen
  /settings/tags               → TagManagementScreen
  /settings/notifications      → NotificationSettingsScreen
  /settings/appearance         → AppearanceScreen (theme)

/purchases/:id                 → PurchaseDetailScreen (deep link)
/invoices/:id                  → InvoiceDetailScreen (deep link)
/invoices/:id/reconciliation   → ReconciliationScreen
/goals                         → GoalsListScreen
  /goals/new                   → GoalFormScreen
  /goals/:id                   → GoalDetailScreen
/debts                         → DebtsListScreen
  /debts/new                   → DebtFormScreen
  /debts/:id                   → DebtDetailScreen
/ai/insights                   → InsightsScreen
```

## Redirect Logic

```dart
GoRouter(
  initialLocation: '/dashboard',
  redirect: (context, state) {
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isAuthenticated && !isAuthRoute) return '/auth/login';
    if (isAuthenticated && isAuthRoute) return '/dashboard';
    return null; // no redirect
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, __) => DashboardScreen()),
        // ... other tab routes
      ],
    ),
  ],
);
```
