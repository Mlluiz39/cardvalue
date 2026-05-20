---

description: "Development tasks for Personal Finance Manager feature"
---

# Tasks: Personal Finance Manager

**Input**: Design documents from `specs/001-personal-finance-manager/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Manual verification per constitution — NO automated test tasks

**Organization**: Tasks grouped by user story for independent implementation

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallelizable (different files, no dependencies)
- **[Story]**: User story label (US1-US7)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization, dependency configuration, directory scaffolding

- [x] T001 Create Flutter project with `flutter create --org com.cardvalue --project-name cardvalue .`
- [x] T002 [P] Configure pubspec.yaml with all dependencies (go_router, riverpod, drift, supabase_flutter, fl_chart, lottie, google_mlkit, firebase_messaging, etc.) per quickstart.md
- [x] T003 [P] Create lib/ directory structure: core/, shared/, features/, services/, routes/
- [x] T004 [P] Create features subdirectories: auth, dashboard, cards, transactions, installments, invoices, debts, goals, ai, calendar, reports, settings
- [x] T005 [P] Configure analysis_options.yaml with Flutter lint rules
- [x] T006 [P] Set up build_runner and code generation config in pubspec.yaml dev_dependencies

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST complete before any user story can begin

- [x] T007 Configure Supabase client initialization in lib/services/supabase_config.dart
- [x] T008 Initialize Firebase Core + FCM in lib/services/firebase_config.dart
- [x] T009 Create app entry point in lib/main.dart with ProviderScope, Supabase init, Firebase init, Material 3 theme
- [x] T010 [P] Create core theme (light/dark/system) in lib/core/theme/app_theme.dart with Material 3
- [x] T011 [P] Create core constants (app constants, API keys config) in lib/core/constants/
- [x] T012 [P] Create core error handling in lib/core/errors/app_exceptions.dart
- [x] T013 [P] Create core extensions in lib/core/extensions/
- [x] T014 [P] Create core network utilities in lib/core/network/
- [x] T015 Set up Drift SQLite database schema in lib/services/drift_database.dart (all 15+ tables)
- [x] T016 Configure GoRouter with auth redirect and ShellRoute in lib/routes/app_router.dart
- [x] T017 [P] Create User profile model in lib/features/auth/domain/models/user.dart
- [x] T018 [P] Implement auth service (login, register, logout, password recovery) in lib/features/auth/
- [x] T019 [P] Create auth screens (login, register, forgot password) in lib/features/auth/presentation/
- [x] T020 [P] Create shared base widgets (AmountField, DatePickerField, CategorySelector, CardSelector) in lib/shared/widgets/
- [x] T021 [P] Create shared utilities (currency formatter, date helpers, validators) in lib/shared/utils/
- [x] T022 Create Supabase database migration with all 15 tables, indexes, and RLS policies per data-model.md
- [x] T023 Create sync outbox table and SyncService in lib/services/sync_service.dart
- [x] T024 Create base repository and data source class templates in lib/services/

**Checkpoint**: Foundation ready — user story implementation can now begin in parallel

---

## Phase 3: User Story 1 — Add Credit Card Purchases with Installments (Priority: P1) 🎯 MVP

**Goal**: User registers credit cards, adds purchases with installments, sees installment timeline and invoice impact

**Independent Test**: Create a card, add a R$1,200 purchase in 12 installments, verify 12 monthly installment records with correct R$100 values across invoice cycles

### Implementation for User Story 1

- [x] T025 [P] [US1] Create Card domain model in lib/features/cards/domain/models/card.dart
- [x] T026 [P] [US1] Create Purchase domain model in lib/features/installments/domain/models/purchase.dart
- [x] T027 [P] [US1] Create Installment domain model in lib/features/installments/domain/models/installment.dart
- [x] T028 [P] [US1] Create InvoiceCycle domain model in lib/features/invoices/domain/models/invoice_cycle.dart
- [x] T029 [P] [US1] Create Receipt domain model in lib/shared/domain/models/receipt.dart
- [x] T030 [P] [US1] Implement Card local data source (Drift) in lib/features/cards/data/local/card_local_ds.dart
- [x] T031 [P] [US1] Implement Card remote data source (Supabase) in lib/features/cards/data/remote/card_remote_ds.dart
- [x] T032 [P] [US1] Implement Card repository in lib/features/cards/data/repository/card_repository.dart
- [x] T033 [P] [US1] Implement Purchase + Installment local data source in lib/features/installments/data/local/
- [x] T034 [P] [US1] Implement Purchase + Installment remote data source in lib/features/installments/data/remote/
- [x] T035 [US1] Implement Purchase repository with installment auto-generation logic in lib/features/installments/data/repository/purchase_repository.dart
- [x] T036 [US1] Implement Installment repository in lib/features/installments/data/repository/installment_repository.dart
- [x] T037 [US1] Implement InvoiceCycle data sources and repository in lib/features/invoices/data/
- [x] T038 [P] [US1] Create shared card widgets (CreditCardWidget, InvoiceTimeline, InstallmentProgress) in lib/shared/widgets/
- [x] T039 [P] [US1] Create cards feature — list screen in lib/features/cards/presentation/card_list_screen.dart
- [x] T040 [P] [US1] Create cards feature — form screen (add/edit) in lib/features/cards/presentation/card_form_screen.dart
- [x] T041 [P] [US1] Create cards feature — detail screen in lib/features/cards/presentation/card_detail_screen.dart
- [x] T042 [US1] Create purchase form screen with installment selector and receipt upload in lib/features/installments/presentation/purchase_form_screen.dart
- [x] T043 [US1] Create purchase detail screen with installment progress view in lib/features/installments/presentation/purchase_detail_screen.dart
- [x] T044 [US1] Implement installment auto-generation: N-1 installments at floor(value/count, 2), last installment as remainder per data-model.md
- [x] T045 [US1] Implement invoice cycle attribution: each installment assigned to correct InvoiceCycle based on card closing_day
- [x] T046 [US1] Implement card limit validation: warn when new purchase would exceed remaining limit
- [x] T047 [US1] Wire up cards routes in GoRouter (/cards, /cards/:id, /cards/new, /cards/:id/edit, /purchases/:id)

**Checkpoint**: User Story 1 fully functional — cards registered, purchases with installments generated, installment progress visible

---

## Phase 4: User Story 2 — Financial Dashboard (Priority: P1)

**Goal**: User sees complete financial snapshot on one screen — totals, charts, card summaries, future obligations

**Independent Test**: Enter transactions for the month, view dashboard, verify all indicators match entered data without navigation

### Implementation for User Story 2

- [x] T048 [P] [US2] Create shared dashboard widgets (ExpenseCard, InvoiceCard, FinancialChart) in lib/shared/widgets/
- [x] T049 [P] [US2] Create SpendingRadar widget in lib/shared/widgets/spending_radar.dart
- [x] T050 [P] [US2] Create MonthlyComparison widget in lib/shared/widgets/monthly_comparison.dart
- [x] T051 [P] [US2] Create UpcomingBills widget in lib/shared/widgets/upcoming_bills.dart
- [x] T052 [P] [US2] Create CategoryPieChart widget in lib/shared/widgets/category_pie_chart.dart
- [x] T053 [US2] Implement dashboard data aggregation providers in lib/features/dashboard/presentation/dashboard_providers.dart
- [x] T054 [US2] Create dashboard main screen with summary cards in lib/features/dashboard/presentation/dashboard_screen.dart
- [x] T055 [US2] Create dashboard charts section (spending by category, monthly trend, card comparison, future installments) in lib/features/dashboard/presentation/
- [x] T056 [US2] Wire up dashboard route in GoRouter (/dashboard) as default tab

**Checkpoint**: User Story 2 complete — dashboard shows all key indicators, charts render with live data

---

## Phase 5: User Story 3 — Invoice Reconciliation (Priority: P1)

**Goal**: User imports credit card invoice (PDF/photo), system auto-matches against registered purchases, flags discrepancies

**Independent Test**: Upload invoice with 5 charges — 3 matched purchases + 2 unknowns; verify system identifies the 2 unknowns

### Implementation for User Story 3

- [x] T057 [P] [US3] Create ReconciliationReport domain model in lib/features/invoices/domain/models/reconciliation_report.dart
- [x] T058 [P] [US3] Create ReconciliationItem domain model in lib/features/invoices/domain/models/reconciliation_item.dart
- [x] T059 [P] [US3] Implement ReconciliationReport data sources and repository in lib/features/invoices/data/
- [x] T060 [P] [US3] Implement ReconciliationItem data sources and repository in lib/features/invoices/data/
- [x] T061 [US3] Implement reconcile-invoice Supabase Edge Function in supabase/functions/reconcile-invoice/index.ts
- [x] T062 [US3] Implement client-side invoice PDF text extraction in lib/services/invoice_parser_service.dart
- [x] T063 [US3] Create reconciliation screen in lib/features/invoices/presentation/reconciliation_screen.dart
- [x] T064 [US3] Implement reconciliation review flow (accept, reject, edit mismatches) in lib/features/invoices/presentation/
- [x] T065 [US3] Implement auto-add — unmatched charges accepted by user become new purchases
- [x] T066 [US3] Add invoice list and per-card invoice history views in lib/features/invoices/presentation/
- [x] T067 [US3] Wire up invoice routes in GoRouter (/invoices/:id, /invoices/:id/reconciliation)

**Checkpoint**: User Story 3 complete — invoices can be imported, reconciled, discrepancies flagged and resolved

---

## Phase 6: User Story 4 — Track Income and Expenses (Priority: P2)

**Goal**: User logs all non-credit transactions (PIX, debit, cash, income), categorizes, and sees running ledger

**Independent Test**: Add 5 transactions of different types (PIX, debit, cash, income, subscription) and verify they appear correctly in category summaries and totals

### Implementation for User Story 4

- [x] T068 [P] [US4] Create Transaction domain model in lib/features/transactions/domain/models/transaction.dart
- [x] T069 [P] [US4] Create Category domain model in lib/features/transactions/domain/models/category.dart
- [x] T070 [P] [US4] Create Tag domain model in lib/features/transactions/domain/models/tag.dart
- [x] T071 [P] [US4] Create RecurrenceRule domain model in lib/features/transactions/domain/models/recurrence_rule.dart
- [x] T072 [P] [US4] Implement Transaction local data source in lib/features/transactions/data/local/transaction_local_ds.dart
- [x] T073 [P] [US4] Implement Transaction remote data source in lib/features/transactions/data/remote/transaction_remote_ds.dart
- [x] T074 [P] [US4] Implement Transaction repository in lib/features/transactions/data/repository/transaction_repository.dart
- [x] T075 [US4] Implement Category data sources and repository in lib/features/transactions/data/
- [x] T076 [US4] Implement Tag data sources and repository (with transaction_tags M:N) in lib/features/transactions/data/
- [x] T077 [US4] Implement RecurrenceRule data sources and repository in lib/features/transactions/data/
- [x] T078 [P] [US4] Create TransactionTile shared widget in lib/shared/widgets/transaction_tile.dart
- [x] T079 [P] [US4] Create transactions list screen in lib/features/transactions/presentation/transaction_list_screen.dart
- [x] T080 [P] [US4] Create transaction form screen (income/expense with payment method) in lib/features/transactions/presentation/transaction_form_screen.dart
- [x] T081 [US4] Create transaction detail screen in lib/features/transactions/presentation/transaction_detail_screen.dart
- [x] T082 [US4] Implement recurring transaction auto-generation service in lib/services/recurring_transaction_service.dart
- [x] T083 [US4] Implement classify-transaction Supabase Edge Function in supabase/functions/classify-transaction/index.ts
- [x] T084 [US4] Implement settings category management screen in lib/features/settings/presentation/category_management_screen.dart
- [x] T085 [US4] Implement settings tag management screen in lib/features/settings/presentation/tag_management_screen.dart
- [x] T086 [US4] Wire up transaction routes in GoRouter (/transactions, /transactions/new, /transactions/:id)

**Checkpoint**: User Story 4 complete — full transaction ledger operational, categories customizable, recurring transactions auto-generated

---

## Phase 7: User Story 5 — Debt Tracking (Priority: P2)

**Goal**: User registers debts with interest, sees payoff projection, tracks extra payments

**Independent Test**: Register a R$10,000 debt at 10% annual interest with 24 installments; verify projected schedule, total interest, and monthly impact

### Implementation for User Story 5

- [x] T087 [P] [US5] Create Debt domain model in lib/features/debts/domain/models/debt.dart
- [x] T088 [P] [US5] Implement Debt local data source in lib/features/debts/data/local/debt_local_ds.dart
- [x] T089 [P] [US5] Implement Debt remote data source in lib/features/debts/data/remote/debt_remote_ds.dart
- [x] T090 [P] [US5] Implement Debt repository in lib/features/debts/data/repository/debt_repository.dart
- [x] T091 [US5] Create debts list screen in lib/features/debts/presentation/debt_list_screen.dart
- [x] T092 [US5] Create debt form screen in lib/features/debts/presentation/debt_form_screen.dart
- [x] T093 [US5] Create debt detail screen with payoff projection chart in lib/features/debts/presentation/debt_detail_screen.dart
- [x] T094 [US5] Implement extra payment logic — recalculate remaining balance, payoff date, reduced interest
- [x] T095 [US5] Wire up debt routes in GoRouter (/debts, /debts/new, /debts/:id)

**Checkpoint**: User Story 5 complete — debts registered, payoff projections visible, extra payments recalculated

---

## Phase 8: User Story 6 — Financial Goals (Priority: P3)

**Goal**: User creates savings goals, tracks progress, sees projected completion date

**Independent Test**: Create R$5,000 emergency fund goal with R$500 monthly contribution; verify progress after 3 simulated contributions

### Implementation for User Story 6

- [x] T096 [P] [US6] Create Goal domain model in lib/features/goals/domain/models/goal.dart
- [x] T097 [P] [US6] Implement Goal local data source in lib/features/goals/data/local/goal_local_ds.dart
- [x] T098 [P] [US6] Implement Goal remote data source in lib/features/goals/data/remote/goal_remote_ds.dart
- [x] T099 [P] [US6] Implement Goal repository in lib/features/goals/data/repository/goal_repository.dart
- [x] T100 [US6] Create goals list screen in lib/features/goals/presentation/goal_list_screen.dart
- [x] T101 [US6] Create goal form screen in lib/features/goals/presentation/goal_form_screen.dart
- [x] T102 [US6] Create goal detail screen with progress chart in lib/features/goals/presentation/goal_detail_screen.dart
- [x] T103 [US6] Implement auto-progress from linked category transactions
- [x] T104 [US6] Wire up goal routes in GoRouter (/goals, /goals/new, /goals/:id)

**Checkpoint**: User Story 6 complete — goals created, progress tracked, completion date projected

---

## Phase 9: User Story 7 — AI Insights and Alerts (Priority: P3)

**Goal**: System proactively generates spending insights, anomaly alerts, invoice predictions, and limit warnings

**Independent Test**: With 2+ months of transaction history, receive a weekly summary with meaningful spending insights and category change detection

### Implementation for User Story 7

- [x] T105 [P] [US7] Create FinancialAlert domain model in lib/features/ai/domain/models/financial_alert.dart
- [x] T106 [P] [US7] Implement FinancialAlert local data source in lib/features/ai/data/local/alert_local_ds.dart
- [x] T107 [P] [US7] Implement FinancialAlert remote data source in lib/features/ai/data/remote/alert_remote_ds.dart
- [x] T108 [P] [US7] Implement FinancialAlert repository in lib/features/ai/data/repository/alert_repository.dart
- [x] T109 [US7] Implement generate-insights Supabase Edge Function with GPT-4o-mini in supabase/functions/generate-insights/index.ts
- [x] T110 [US7] Implement process-receipt-ocr Supabase Edge Function in supabase/functions/process-receipt-ocr/index.ts
- [x] T111 [US7] Create AI insights screen in lib/features/ai/presentation/insights_screen.dart
- [x] T112 [US7] Implement notification service (FCM + flutter_local_notifications) in lib/services/notification_service.dart
- [x] T113 [US7] Configure weekly cron job for insight generation in supabase/migrations/
- [x] T114 [US7] Implement card limit warning alert (>=80% usage) in lib/features/ai/
- [x] T115 [US7] Implement next-month invoice prediction display on dashboard
- [x] T116 [US7] Add spending anomaly detection, weekly summary generation, and alert creation
- [x] T117 [US7] Wire up AI insights route in GoRouter (/ai/insights)

**Checkpoint**: User Story 7 complete — insights generated weekly, anomaly alerts triggered, limit warnings active

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Features that span multiple user stories and final quality improvements

- [x] T118 [P] Create financial calendar view in lib/features/calendar/presentation/calendar_screen.dart
- [x] T119 [P] Create reports and data export feature in lib/features/reports/
- [x] T120 [P] Create settings screens (profile, appearance, notification settings) in lib/features/settings/
- [x] T121 [P] Implement global search across transactions, cards, merchants, categories in lib/features/transactions/
- [x] T122 [P] Implement receipt photo capture/upload and attachment display flow
- [x] T123 [P] Implement responsive layout with ResponsiveFramework (phone/tablet/desktop breakpoints)
- [x] T124 [P] Create onboarding screens for new users (first card, first transaction)
- [x] T125 [P] Implement light/dark theme toggle with smooth animation in lib/features/settings/
- [x] T126 [P] Add animated page transitions and Lottie onboarding animations
- [x] T127 Run quickstart.md validation checklist to verify all setup steps
- [x] T128 Final manual verification of all features per constitution guidelines

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **User Stories (Phase 3-9)**: All depend on Foundational phase completion
  - User stories CAN proceed in parallel (if staffed) since each targets different files
  - Recommended: sequential in priority order (P1 → P2 → P3)
- **Polish (Phase 10)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1 - Cards & Purchases (P1)**: Can start after Foundational — no story dependencies
- **US2 - Dashboard (P1)**: Can start after Foundational — depends on US1 data existing for full value but independently testable with seeded data
- **US3 - Reconciliation (P1)**: Can start after Foundational — depends on US1 entities (InvoiceCycle, Purchase) but independent implementation
- **US4 - Transactions (P2)**: Can start after Foundational — independent of US1-US3
- **US5 - Debts (P2)**: Can start after Foundational — independent of US1-US4
- **US6 - Goals (P3)**: Can start after Foundational — depends on US4 (Transaction category link) for full feature
- **US7 - AI Insights (P3)**: Can start after Foundational — benefits from US1-US6 data but independently testable

### Within Each User Story

- Models before data sources
- Data sources before repositories
- Repositories before presentation
- Core implementation before integration with navigation

### Parallel Opportunities

- All Setup [P] tasks can run in parallel
- All Foundational [P] tasks can run in parallel
- Once Foundational done, all user stories can proceed in parallel
- Models within a story marked [P] run in parallel
- Data sources within a story marked [P] run in parallel
- Screens within a story marked [P] run in parallel
- Edge Functions across stories marked [P] run in parallel

---

## Parallel Example: User Story 1 (Installments)

```bash
# Launch all domain models together:
Task: T025 Create Card domain model
Task: T026 Create Purchase domain model
Task: T027 Create Installment domain model
Task: T028 Create InvoiceCycle domain model
Task: T029 Create Receipt domain model

# Launch all local data sources together:
Task: T030 Implement Card local data source
Task: T033 Implement Purchase + Installment local data source

# Launch all remote data sources together:
Task: T031 Implement Card remote data source
Task: T034 Implement Purchase + Installment remote data source

# Launch all UI screens together:
Task: T039 Create card list screen
Task: T040 Create card form screen
Task: T041 Create card detail screen
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: User Story 1 (Cards & Purchases with Installments)
4. **STOP and VALIDATE**: Test US1 independently — create card, add installment purchase, verify timeline
5. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 (Cards & Installments) → **MVP** — deploy/demo
3. Add US2 (Dashboard) → deploy/demo
4. Add US3 (Reconciliation) → deploy/demo
5. Add US4 (Transactions) → deploy/demo
6. Add US5 (Debts) → deploy/demo
7. Add US6 (Goals) → deploy/demo
8. Add US7 (AI Insights) → deploy/demo
9. Polish → final release

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: US1 (Cards & Installments)
   - Developer B: US2 (Dashboard)
   - Developer C: US3 (Reconciliation)
3. Remaining stories assigned as team capacity allows
4. Regular integration checkpoints to ensure independent stories compose correctly

---

## Summary

| Phase | Story | Priority | Task Count |
|-------|-------|----------|-----------|
| 1 | Setup | — | 6 |
| 2 | Foundational | — | 18 |
| 3 | US1 — Cards & Purchases | P1 | 23 |
| 4 | US2 — Dashboard | P1 | 9 |
| 5 | US3 — Invoice Reconciliation | P1 | 11 |
| 6 | US4 — Income & Expenses | P2 | 19 |
| 7 | US5 — Debt Tracking | P2 | 9 |
| 8 | US6 — Financial Goals | P3 | 9 |
| 9 | US7 — AI Insights | P3 | 13 |
| 10 | Polish & Cross-Cutting | — | 11 |
| | **Total** | | **128** |

**Suggested MVP Scope**: Phases 1, 2, and 3 (User Story 1 only) = 47 tasks

**Parallel Opportunities**: Within each phase, ~40-50% of tasks are parallelizable

**Independent Test Criteria**:
- **US1**: Create card, add purchase with installments, verify installment records and invoice cycle attribution
- **US2**: View dashboard with all indicators matching entered transaction data
- **US3**: Upload invoice, verify match/unmatched/discrepancy identification
- **US4**: Add transactions of each type, verify category summaries and totals
- **US5**: Register debt, verify payoff projection and extra payment recalculation
- **US6**: Create goal, simulate contributions, verify progress tracking
- **US7**: Generate insights with 2+ months data, verify anomaly alerts and predictions
