# Feature Specification: Personal Finance Manager

**Feature Branch**: `001-personal-finance-manager`

**Created**: 2026-05-18

**Status**: Draft

**Input**: User requested a modern personal finance management application with focus on credit card installment control, expense reconciliation, and complete financial organization.

## User Scenarios & Testing

### User Story 1 - Add and Organize Credit Card Purchases with Automatic Installments (Priority: P1)

A user buys an item on their credit card and wants to track it across all future bills. They enter the purchase once, specifying the total value, number of installments, and which card was used. The system automatically generates all future installment records, calculates the impact on upcoming invoices, and shows progress (paid vs remaining installments). The user can see at a glance which purchases are still active and how each card's future bills look.

**Why this priority**: Credit card installment tracking is the core problem the system solves. Without this, users cannot reliably know their future financial obligations.

**Independent Test**: User can create a purchase with 12 installments and verify that all 12 monthly records appear in their invoice timeline with correct values and dates.

**Acceptance Scenarios**:

1. **Given** the user has registered a credit card with a R$ 5,000 limit, **When** they add a purchase of R$ 1,200 in 12 installments, **Then** the system creates 12 installment records of R$ 100 each (or proportional) spanning the next 12 months.
2. **Given** a purchase with 3 installments where 2 have already been paid, **When** the user views the purchase details, **Then** the system shows 2 paid installments and 1 remaining, with the total paid amount and remaining balance.
3. **Given** the user adds a new purchase, **When** they assign it to a credit card whose remaining limit would be exceeded, **Then** the system warns them before confirming the purchase.
4. **Given** a purchase with installment records, **When** any installment date falls on the card's closing date, **Then** it is correctly attributed to the corresponding invoice cycle.

---

### User Story 2 - View Financial Dashboard with Key Indicators (Priority: P1)

A user opens the application and immediately sees their financial snapshot: total spent this month, credit card balance, future installment obligations, available credit limits, and spending breakdown by category. Charts show monthly trends and comparisons. The dashboard serves as a command center that answers "where does my money go?" without any clicks.

**Why this priority**: The dashboard is the first thing users see and determines whether they perceive the app as valuable. Without it, the app feels like a data entry tool rather than a financial manager.

**Independent Test**: User can view all key financial indicators on a single screen and verify that totals match their entered transactions without navigating to other screens.

**Acceptance Scenarios**:

1. **Given** the user has entered transactions for the current month, **When** they view the dashboard, **Then** they see: total monthly spending, total credit card spending, future installment total, total PIX transactions, total debit spending, current monthly savings, and spending by category — all updated in real time based on entered data.
2. **Given** the user has 6+ months of transaction history, **When** they view the dashboard, **Then** they can see a monthly trend chart showing spending evolution.
3. **Given** the user has multiple credit cards, **When** viewing the dashboard, **Then** they see a comparative view of spending across cards and the available limit for each.
4. **Given** the user has upcoming installment obligations, **When** they view the dashboard, **Then** they see a future installments chart projecting obligations over the next months.

---

### User Story 3 - Reconcile Credit Card Invoice with Registered Purchases (Priority: P1)

At the end of the billing cycle, a user receives their credit card invoice (PDF or paper). They upload the invoice or take a photo. The system automatically compares the bank's charges against what the user has registered in the app, flagging unknown charges, price discrepancies, and missing entries. The user can then match, reject, or investigate each discrepancy.

**Why this priority**: Invoice reconciliation directly solves the user's core problem of forgetting purchases and not knowing if the bill is correct. It's the safety net that catches errors and omissions.

**Independent Test**: User uploads an invoice containing 5 charges — 3 that match registered purchases and 2 that are unknown. The system correctly identifies the 2 unknown charges.

**Acceptance Scenarios**:

1. **Given** a user has registered 10 purchases on a card and receives the monthly invoice, **When** they upload the invoice file, **Then** the system compares every invoice line item against registered purchases and produces a reconciliation report showing: matched purchases, unmatched charges, and any value differences.
2. **Given** the invoice has a charge of R$ 250 but the user registered the purchase as R$ 200, **When** reconciliation runs, **Then** the system flags this as a value discrepancy and shows the difference.
3. **Given** the user has reviewed all discrepancies, **When** they accept unmatched charges as valid, **Then** those charges are added to their purchase records automatically.
4. **Given** the user has paper or digital invoice files, **When** they upload a photo or PDF, **Then** the system extracts purchase data automatically regardless of format.

---

### User Story 4 - Track All Income and Expenses (Non-Credit) (Priority: P2)

Beyond credit cards, a user wants to track their full financial life: salary, freelance income, PIX transfers, debit purchases, cash spending, bills, subscriptions, and other recurring payments. They can log each transaction with category, date, and optional notes. The system keeps a running ledger and categorizes spending automatically.

**Why this priority**: Credit cards are only part of the picture. Users need a complete view to understand their full financial situation.

**Independent Test**: User can add 5 transactions of different types (PIX, debit, cash, income) and verify they appear correctly in their respective category summaries and totals.

**Acceptance Scenarios**:

1. **Given** the user receives income, **When** they log a salary entry, **Then** it appears under income with the correct category, date, and value, and updates the monthly savings calculation.
2. **Given** the user makes a PIX transfer, **When** they log it as an expense, **Then** it appears in the PIX total for the month and under the assigned category.
3. **Given** the user has recurring subscriptions (e.g., Netflix, Spotify), **When** they register them as recurring expenses, **Then** the system automatically creates transactions each cycle and alerts the user before charging.
4. **Given** a transaction entry, **When** the user assigns a category, **Then** the system optionally suggests categories based on similar past transactions and auto-categorizes future entries.

---

### User Story 5 - Manage Debts and Track Payment Progress (Priority: P2)

A user has outstanding debts (loans, financing, informal debts) and wants to track them in one place. They register the debt amount, interest rate, number of installments, and priority. The system projects the monthly impact, shows the total cost with interest, and displays a progress chart toward full payment.

**Why this priority**: Debts are a major source of financial stress. Having visibility into payoff progress and total cost helps users make better repayment decisions.

**Independent Test**: User registers a debt with 24 remaining installments and can see the projected payment schedule, total interest cost, and monthly impact on their budget.

**Acceptance Scenarios**:

1. **Given** a user has a debt of R$ 10,000 with 10% annual interest, **When** they register it with the total amount and interest terms, **Then** the system calculates the projected installment value, total repayment cost, and payoff timeline.
2. **Given** a user makes an extra payment toward a debt, **When** they record the additional payment, **Then** the system recalculates the remaining balance, new payoff date, and reduced interest cost.
3. **Given** multiple debts registered, **When** viewing debt management, **Then** the user sees debts ordered by priority with a visual progress bar for each and a combined monthly impact.

---

### User Story 6 - Create Financial Goals and Track Progress (Priority: P3)

A user wants to save toward specific goals: emergency fund, vacation, new car, or paying off a credit card. They set a target amount, deadline, and optionally link recurring savings contributions. The system shows progress toward each goal and suggests adjustments if they fall behind schedule.

**Why this priority**: Goals provide motivation and purpose for financial discipline. While not essential for basic tracking, they transform the app from a passive ledger into an active financial planning tool.

**Independent Test**: User creates a goal of R$ 5,000 for an emergency fund, sets monthly contributions of R$ 500, and can see progress after 3 simulated contributions.

**Acceptance Scenarios**:

1. **Given** a user creates a goal with target value and deadline, **When** they view the goal, **Then** they see current progress, remaining amount, monthly target contribution, and projected completion date based on current savings rate.
2. **Given** a goal is linked to a savings category, **When** the user logs transactions in that category, **Then** the goal progress updates automatically.
3. **Given** a goal is nearing its deadline but is behind schedule, **When** the user views it, **Then** the system suggests increased monthly contributions and shows the adjusted timeline.

---

### User Story 7 - Receive Intelligent Financial Insights and Alerts (Priority: P3)

A user wants the system to proactively help them make better financial decisions. The system analyzes spending patterns and generates weekly summaries, anomaly alerts (e.g., "You spent 35% more on food delivery this month"), spending category warnings, and predictions for next month's credit card bill. It also reminds users of upcoming payments, approaching card limits, and other important events.

**Why this priority**: AI-driven insights differentiate the app from simple spreadsheets and provide proactive value that keeps users engaged. However, they depend on sufficient data and are additive to core tracking features.

**Independent Test**: User receives a weekly summary email or in-app notification with meaningful spending insights derived from their transaction history.

**Acceptance Scenarios**:

1. **Given** the user has 2+ months of transaction history, **When** the weekly analysis runs, **Then** the system generates a summary comparing current spending to the previous period, highlighting categories with significant changes.
2. **Given** a user's spending in a category has increased more than a configurable threshold (default: 20%) compared to the previous month, **When** the threshold is crossed, **Then** the user receives an alert about the increase.
3. **Given** a credit card is approaching 80% of its limit, **When** a new purchase would exceed the threshold, **Then** the user receives a limit warning before the purchase is finalized.
4. **Given** a user has installment records, **When** viewing the dashboard, **Then** the system displays a prediction of next month's total invoice value based on existing records.

---

### Edge Cases

- What happens when a user installs the app and has no data? The app should show onboarding screens prompting them to add their first card, first transaction, or import data.
- How does the system handle a purchase with non-standard installment values (e.g., first installment different from the rest, or interest-bearing installments)? The user should be able to manually adjust individual installment values.
- What happens when a credit card has multiple purchases that collectively exceed the limit? The system warns before adding and tracks regardless, as banks may authorize over-limit transactions.
- How does the system handle credit card invoice reconciliation when the user has multiple cards? Each invoice is associated with a specific card, and comparison is done per-card.
- What happens when the same purchase appears on two different invoices (e.g., delayed charge)? The system can match by approximate date, value, and merchant name, and flag duplicates for user review.
- How does the system handle deleted or modified purchases that already have installment records generated? Changes propagate to all future installments, with user confirmation before modifying.
- What happens to financial goals when users withdraw saved money? Goals track progress bi-directionally — withdrawals reduce progress.
- How does the system handle currency format variations and decimal separators in PDF invoices? The parser normalizes all numeric values to a standard format based on locale detection.

## Requirements

### Functional Requirements

- **FR-001**: Users MUST be able to register one or more credit cards with name, bank name, credit limit, closing day, due day, color, brand, and card type (virtual/physical).
- **FR-002**: Users MUST be able to add purchases to any registered credit card, specifying value, merchant name, category, date, optional note, optional receipt attachment, and number of installments.
- **FR-003**: When a user adds a purchase with multiple installments, the system MUST automatically generate one record per installment with the correct proportional value and month, distributed across the appropriate invoice cycles.
- **FR-004**: Users MUST be able to view, for each purchase, a summary showing total value, number of paid installments, number of remaining installments, total paid amount, and remaining balance.
- **FR-005**: Users MUST be able to import a credit card invoice (via PDF upload or photo) and the system MUST compare imported line items against registered purchases, producing a reconciliation report showing matches, unknown charges, and value discrepancies.
- **FR-006**: Users MUST be able to accept, reject, or edit each item in the reconciliation report.
- **FR-007**: Users MUST be able to register income transactions (salary, freelance, sales, other) with date, value, category, and optional notes.
- **FR-008**: Users MUST be able to register expense transactions of any type (PIX, debit, cash, bills, subscriptions, rent, financing, loans) with date, value, category, optional notes, and optional receipt attachment.
- **FR-009**: The system MUST categorize all transactions and allow users to customize categories (create, edit, delete, rename).
- **FR-010**: Users MUST be able to view a comprehensive dashboard showing at minimum: total monthly spending, total credit card spending, total future installment value, PIX total, debit total, open debts total, available credit limit, next invoice value, monthly savings, spending by category, and financial alerts.
- **FR-011**: The dashboard MUST include at least four visualization types: spending by category (proportional chart), monthly spending evolution (trend chart), card comparison (comparative chart), and future installment projection chart.
- **FR-012**: Users MUST be able to register debts with total amount, interest rate, number of remaining installments, due dates, priority level, and optional negotiation notes.
- **FR-013**: For each registered debt, the system MUST display the projected payment schedule, total interest cost, monthly budget impact, and estimated payoff date.
- **FR-014**: Users MUST be able to create financial goals with target value, deadline, optional linked savings category, and optional recurring contribution value.
- **FR-015**: The system MUST track and display progress toward each goal, showing current value, percentage complete, remaining time, and recommended monthly contribution.
- **FR-016**: The system MUST analyze spending patterns periodically and generate: weekly spending summaries, anomaly detection alerts (category spending changes exceeding configurable thresholds), and next-month invoice predictions.
- **FR-017**: Users MUST receive timely notifications for: upcoming credit card closing dates, approaching due dates, card limits nearing capacity, goal milestones, and upcoming recurring payments.
- **FR-018**: Users MUST be able to view a financial calendar showing all events: payment due dates, installment dates, recurring charges, income dates, and card closing dates.
- **FR-019**: Users MUST be able to attach receipt files (photos, PDFs) to any transaction and view them later from the transaction detail screen.
- **FR-020**: Users MUST be able to search across all transactions, cards, categories, and merchants using a global search function.
- **FR-021**: The system MUST support recurring transactions (e.g., subscriptions, rent) that auto-generate entries on their schedule and notify the user before each occurrence.
- **FR-022**: Users MUST be able to export their financial data (transactions, reports) in standard formats for external use.
- **FR-023**: Users MUST be able to organize transactions using customizable tags in addition to categories.
- **FR-024**: The system MUST support both light and dark visual themes with smooth transitions.
- **FR-025**: The system MUST be fully functional on both mobile devices (phones, tablets) and desktop browsers with responsive layout adaptation.

### Key Entities

- **User**: Person who owns the financial data. Has authentication credentials, profile preferences (theme, currency, locale), and notification settings.
- **Credit Card**: A payment card account with limit, billing cycle (closing and due dates), brand, color, and type (virtual/physical). Belongs to one user and can have many purchases.
- **Purchase**: A credit card transaction with merchant, value, category, date, and optional receipt. Can be a single payment or split into multiple installments.
- **Installment**: A single payment obligation within a multi-installment purchase. Has sequence number (e.g., 3/12), value, due month, payment status (paid/pending), and belongs to one purchase and one invoice cycle.
- **Invoice Cycle**: A monthly billing period for a credit card, defined by closing and due dates. Aggregates all installments and single charges falling within that cycle.
- **Transaction**: A generic financial movement (income or expense) of any type (PIX, debit, cash, transfer, bill). Has value, date, category, type, optional tags, optional receipt, and optional recurrence rule.
- **Category**: A label for classifying transactions (e.g., Food, Transport, Salary). Users can create, edit, and delete custom categories.
- **Tag**: An optional extra label for cross-category organization of transactions (e.g., "Emergency", "Travel").
- **Debt**: A financial obligation with principal amount, interest rate, remaining installments, and priority. Tracks payment progress and projects payoff timeline.
- **Goal**: A savings target with target value, deadline, current progress, and optional linked savings category and recurring contribution. Tracks progress toward financial objectives.
- **Recurrence Rule**: A definition for automatically repeating transactions (frequency, interval, end condition). Linked to recurring transactions.
- **Reconciliation Report**: A snapshot comparing an imported invoice against registered purchases. Contains match status for each line item (matched, unknown, value discrepancy) and user decisions (accept, reject, edit).
- **Financial Alert**: A system-generated notification triggered by configurable rules (budget threshold exceeded, limit approaching, duplicate spending detected, etc.).
- **Receipt**: An attached file (image or PDF) linked to a transaction for proof of purchase. Stores the original file and any extracted metadata.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A user can register a credit card, add their first purchase with installments, see the installment timeline, and reconcile their first invoice — all within 10 minutes of first use.
- **SC-002**: Users can view their complete financial picture (all key indicators) on the dashboard within 2 seconds of app launch with up to 12 months of transaction history loaded.
- **SC-003**: At least 90% of line items on a typical Brazilian credit card invoice (Nubank, Inter, Itaú, Bradesco, Santander formats) are correctly matched or flagged as discrepancies during automatic reconciliation.
- **SC-004**: 80% of users who enter 10+ transactions in their first week return to the app in the second week (indicating perceived ongoing value).
- **SC-005**: Users can complete the transaction entry flow (add a purchase with installments) in under 60 seconds after initial familiarization.
- **SC-006**: The system correctly generates installment records for 100% of multi-installment purchases with no data loss or miscalculation.
- **SC-007**: Financial insight alerts reach users within 1 hour of the triggering condition being met (e.g., category spending threshold crossed).
- **SC-008**: The application loads and functions correctly on mobile browsers (Chrome, Safari) and desktop browsers (Chrome, Firefox, Edge) with no loss of core functionality.

## Assumptions

- Users are individuals managing personal finances in Brazil, with Brazilian Real (BRL) as the primary currency.
- The initial release targets single-user personal finance management; multi-tenant/multi-user SaaS features are future scope.
- Users have a smartphone with camera capability for receipt photos and basic digital literacy.
- Credit card invoice PDFs follow common Brazilian bank formats; the system prioritizes the most common formats (Nubank, Inter, Itaú, Bradesco, Santander) with a generic fallback parser.
- Users have internet connectivity for most operations; limited offline capability (view-only of cached data) is acceptable for v1.
- Notification delivery starts with in-app and push notifications; email and WhatsApp channels are future additions.
- The financial dashboard follows a monthly view cycle, with week-level drill-down available.
- Category suggestions and auto-categorization improve over time as the user logs more transactions.
- Users may have multiple credit cards, bank accounts, and financial accounts — all managed within a single user profile.
- The system is designed for individual financial control, not shared or joint account management.
