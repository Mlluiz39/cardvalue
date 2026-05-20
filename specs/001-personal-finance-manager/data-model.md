# Data Model — Personal Finance Manager

## Entity Relationship Overview

```
User (1) ────< Card (0..N)
User (1) ────< Transaction (0..N)
User (1) ────< Debt (0..N)
User (1) ────< Goal (0..N)
User (1) ────< Category (0..N)
User (1) ────< FinancialAlert (0..N)
User (1) ────< RecurrenceRule (0..N)

Card (1) ────< Purchase (0..N)
Card (1) ────< InvoiceCycle (0..N)

Purchase (1) ────< Installment (1..N)
Purchase (1) ────< Receipt (0..1)

InvoiceCycle (1) ────< Installment (0..N)
InvoiceCycle (1) ────< ReconciliationReport (0..1)

Transaction (1) ────< Receipt (0..1)
Transaction (1) ────< Tag (0..N) —< (M:N via transaction_tags)
Transaction (1) ────< RecurrenceRule (0..1)
Transaction (1) ────< Category (1)

Goal (1) ────< Transaction (0..N) — via category link (optional)
Debt (1) ────< Transaction (0..N) — payments
```

---

## Entities

### User
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK, default `gen_random_uuid()` |
| `name` | TEXT | NOT NULL |
| `email` | TEXT | NOT NULL, UNIQUE |
| `avatar_url` | TEXT | nullable |
| `created_at` | TIMESTAMPTZ | NOT NULL, default `now()` |
| `updated_at` | TIMESTAMPTZ | NOT NULL, default `now()` |
| `locale` | TEXT | default `'pt-BR'` |
| `currency` | TEXT | default `'BRL'` |
| `theme_preference` | TEXT | default `'system'`, one of `'light'`, `'dark'`, `'system'` |
| `notification_settings` | JSONB | default `'{"push":true,"insights":true,"alerts":true}'` |

**Source**: `auth.users` (Supabase Auth) + `public.users` profile table.

**Validation**:
- `email` must be valid format
- `name` min 2 chars
- `theme_preference` only `light`, `dark`, or `system`

---

### Card
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `user_id` | UUID | FK → users.id, NOT NULL, ON DELETE CASCADE |
| `bank_name` | TEXT | NOT NULL |
| `card_name` | TEXT | NOT NULL |
| `brand` | TEXT | NOT NULL (`visa`, `mastercard`, `amex`, `elo`, `hipercard`, `other`) |
| `card_type` | TEXT | NOT NULL default `'physical'`, one of `'physical'`, `'virtual'` |
| `limit_amount` | DECIMAL(12,2) | NOT NULL, CHECK ≥ 0 |
| `closing_day` | INTEGER | NOT NULL, CHECK 1-31 |
| `due_day` | INTEGER | NOT NULL, CHECK 1-31 |
| `color` | TEXT | nullable (hex color) |
| `is_active` | BOOLEAN | default `true` |
| `created_at` | TIMESTAMPTZ | default `now()` |
| `updated_at` | TIMESTAMPTZ | default `now()` |

**Relationships**:
- One user has many cards
- One card has many purchases
- One card has many invoice cycles

**Validation**:
- `limit_amount` ≥ 0
- `closing_day` 1-31 (cap to 28 if month shorter)
- `due_day` 1-31

---

### Purchase
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `card_id` | UUID | FK → cards.id, NOT NULL, ON DELETE CASCADE |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `merchant_name` | TEXT | NOT NULL |
| `total_amount` | DECIMAL(12,2) | NOT NULL, CHECK > 0 |
| `category_id` | UUID | FK → categories.id, NOT NULL |
| `purchase_date` | DATE | NOT NULL |
| `installment_count` | INTEGER | NOT NULL, CHECK ≥ 1 |
| `notes` | TEXT | nullable |
| `is_reconciled` | BOOLEAN | default `false` |
| `created_at` | TIMESTAMPTZ | default `now()` |
| `updated_at` | TIMESTAMPTZ | default `now()` |

**Relationships**:
- Belongs to one card
- Has many installments (1..N)
- Optionally has one receipt

**Validation**:
- `total_amount` > 0
- `installment_count` ≥ 1
- If `installment_count = 1`, a single non-installment purchase

**State Transitions**:
- `pending` → `reconciled` (when matched on invoice)
- `reconciled` ↔ `pending` (user can undo)

---

### Installment
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `purchase_id` | UUID | FK → purchases.id, NOT NULL, ON DELETE CASCADE |
| `invoice_cycle_id` | UUID | FK → invoice_cycles.id, nullable |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `sequence_number` | INTEGER | NOT NULL, CHECK ≥ 1 |
| `total_installments` | INTEGER | NOT NULL, CHECK ≥ 1 |
| `amount` | DECIMAL(12,2) | NOT NULL, CHECK > 0 |
| `due_date` | DATE | NOT NULL |
| `status` | TEXT | NOT NULL default `'pending'`, one of `'pending'`, `'paid'` |
| `paid_at` | DATE | nullable |
| `created_at` | TIMESTAMPTZ | default `now()` |

**Relationships**:
- Belongs to one purchase (via purchase_id)
- Belongs to one invoice cycle (via invoice_cycle_id)
- Unique constraint: (purchase_id, sequence_number)

**Validation**:
- `sequence_number` ≤ `total_installments`
- `amount` must match: sum of all installments = purchase.total_amount (± rounding adjustment)
- `due_date` computed from purchase_date + card's closing cycle

**State Transitions**:
- `pending` → `paid` (when user marks as paid or invoice reconciliation confirms)
- `paid` → `pending` (user can undo)

**Rounding Strategy**: First N-1 installments = `floor(amount / count * 100) / 100`. Last installment = `total - sum(first N-1)`.

---

### InvoiceCycle
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `card_id` | UUID | FK → cards.id, NOT NULL, ON DELETE CASCADE |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `month` | INTEGER | NOT NULL, CHECK 1-12 |
| `year` | INTEGER | NOT NULL |
| `closing_date` | DATE | NOT NULL |
| `due_date` | DATE | NOT NULL |
| `total_amount` | DECIMAL(12,2) | default 0, CHECK ≥ 0 |
| `is_paid` | BOOLEAN | default `false` |
| `paid_at` | DATE | nullable |
| `notes` | TEXT | nullable |
| `created_at` | TIMESTAMPTZ | default `now()` |
| `updated_at` | TIMESTAMPTZ | default `now()` |

**Unique**: (card_id, month, year)

**Validation**:
- `closing_date` < `due_date` (within same cycle)
- `total_amount` is auto-computed as sum of linked installment amounts

**State Transitions**:
- `open` → `closed` (after closing_date passes)
- `closed` → `paid` (user marks as paid)
- `paid` → `closed` (undo payment)

---

### Transaction
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `type` | TEXT | NOT NULL, one of `'income'`, `'expense'` |
| `payment_method` | TEXT | one of `'pix'`, `'debit'`, `'cash'`, `'transfer'`, `'boleto'`, `'subscription'`, `'other'` |
| `category_id` | UUID | FK → categories.id, NOT NULL |
| `description` | TEXT | NOT NULL |
| `amount` | DECIMAL(12,2) | NOT NULL, CHECK > 0 |
| `transaction_date` | DATE | NOT NULL |
| `notes` | TEXT | nullable |
| `recurrence_rule_id` | UUID | FK → recurrence_rules.id, nullable |
| `debt_id` | UUID | FK → debts.id, nullable |
| `goal_id` | UUID | FK → goals.id, nullable |
| `created_at` | TIMESTAMPTZ | default `now()` |
| `updated_at` | TIMESTAMPTZ | default `now()` |

**Relationships**:
- Optionally linked to a RecurrenceRule (for subscriptions, recurring payments)
- Optionally linked to a Debt (for debt payments)
- Optionally linked to a Goal (for goal contributions)
- Can have multiple Tags (M:N via transaction_tags)

**Validation**:
- `amount` > 0
- `type` must be `income` or `expense`
- If `recurrence_rule_id` is set, the transaction is a template for recurring entries

**State Transitions**: 
- `active` → `cancelled` (hard delete not allowed after reconciliation; soft delete via `deleted_at`)

---

### Category
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `name` | TEXT | NOT NULL |
| `icon` | TEXT | nullable (Material icon name) |
| `color` | TEXT | nullable (hex color) |
| `type` | TEXT | NOT NULL, one of `'income'`, `'expense'`, `'both'` |
| `is_system` | BOOLEAN | default `false` (system categories cannot be deleted) |
| `sort_order` | INTEGER | default 0 |
| `created_at` | TIMESTAMPTZ | default `now()` |

**Unique**: (user_id, name)

**System Categories (seeded)**:
- Alimentação, Transporte, Mercado, Saúde, Streaming, Lazer, Moradia, Educação, Vestuário, Salário, Renda Extra, Outros

**Validation**:
- System categories (`is_system = true`) cannot be deleted; can be renamed

---

### Tag
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `name` | TEXT | NOT NULL |
| `color` | TEXT | nullable |
| `created_at` | TIMESTAMPTZ | default `now()` |

**Unique**: (user_id, name)

---

### TransactionTag (M:N join)
| Field | Type | Constraints |
|-------|------|------------|
| `transaction_id` | UUID | FK → transactions.id, ON DELETE CASCADE |
| `tag_id` | UUID | FK → tags.id, ON DELETE CASCADE |

**PK**: (transaction_id, tag_id)

---

### Debt
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `title` | TEXT | NOT NULL |
| `total_amount` | DECIMAL(12,2) | NOT NULL, CHECK > 0 |
| `remaining_amount` | DECIMAL(12,2) | NOT NULL, CHECK ≥ 0 |
| `interest_rate` | DECIMAL(5,2) | default 0 (percentage) |
| `total_installments` | INTEGER | NOT NULL, CHECK ≥ 1 |
| `remaining_installments` | INTEGER | NOT NULL, CHECK ≥ 0 |
| `due_date` | DATE | NOT NULL |
| `priority` | TEXT | NOT NULL, one of `'low'`, `'medium'`, `'high'` |
| `status` | TEXT | NOT NULL default `'active'`, one of `'active'`, `'paid'`, `'negotiated'` |
| `notes` | TEXT | nullable |
| `created_at` | TIMESTAMPTZ | default `now()` |
| `updated_at` | TIMESTAMPTZ | default `now()` |

**Validation**:
- `remaining_amount` ≤ `total_amount`
- `remaining_installments` ≤ `total_installments`
- When extra payment recorded: recalculate `remaining_amount`, `remaining_installments`, payoff date

**State Transitions**:
- `active` → `paid` (remaining_amount = 0)
- `active` → `negotiated` (restructured)
- `negotiated` → `active` (re-activated)

---

### Goal
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `title` | TEXT | NOT NULL |
| `target_amount` | DECIMAL(12,2) | NOT NULL, CHECK > 0 |
| `current_amount` | DECIMAL(12,2) | default 0, CHECK ≥ 0 |
| `deadline` | DATE | nullable |
| `category_id` | UUID | FK → categories.id, nullable (linked savings category) |
| `monthly_contribution` | DECIMAL(12,2) | nullable (recommended monthly target) |
| `status` | TEXT | NOT NULL default `'active'`, one of `'active'`, `'completed'`, `'cancelled'` |
| `created_at` | TIMESTAMPTZ | default `now()` |
| `updated_at` | TIMESTAMPTZ | default `now()` |

**Validation**:
- `current_amount` ≤ `target_amount`
- `monthly_contribution` ≥ 0 if set

**State Transitions**:
- `active` → `completed` (current_amount ≥ target_amount)
- `active` → `cancelled`
- `completed` → `active` (if funds withdrawn)

---

### Receipt
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `transaction_id` | UUID | FK → transactions.id, nullable, ON DELETE SET NULL |
| `purchase_id` | UUID | FK → purchases.id, nullable, ON DELETE SET NULL |
| `file_url` | TEXT | NOT NULL (Supabase Storage URL) |
| `file_type` | TEXT | NOT NULL, one of `'image'`, `'application/pdf'` |
| `extracted_text` | TEXT | nullable (OCR result) |
| `extracted_data` | JSONB | nullable `{merchant, value, date, category}` |
| `created_at` | TIMESTAMPTZ | default `now()` |

**Validation**: Either `transaction_id` or `purchase_id` must be set (or both, if linked).

---

### ReconciliationReport
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `invoice_cycle_id` | UUID | FK → invoice_cycles.id, NOT NULL, UNIQUE |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `status` | TEXT | NOT NULL default `'draft'`, one of `'draft'`, `'reviewed'`, `'finalized'` |
| `summary` | JSONB | NOT NULL `{total_invoice_items, matched, unmatched, discrepancies}` |
| `created_at` | TIMESTAMPTZ | default `now()` |
| `updated_at` | TIMESTAMPTZ | default `now()` |

---

### ReconciliationItem
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `report_id` | UUID | FK → reconciliation_reports.id, NOT NULL, ON DELETE CASCADE |
| `invoice_description` | TEXT | NOT NULL |
| `invoice_amount` | DECIMAL(12,2) | NOT NULL |
| `match_status` | TEXT | NOT NULL, one of `'matched'`, `'unmatched'`, `'discrepancy'` |
| `matched_purchase_id` | UUID | FK → purchases.id, nullable |
| `registered_amount` | DECIMAL(12,2) | nullable |
| `difference` | DECIMAL(12,2) | nullable |
| `user_action` | TEXT | nullable, one of `'accept'`, `'reject'`, `'edit'` |
| `created_at` | TIMESTAMPTZ | default `now()` |

---

### FinancialAlert
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `type` | TEXT | NOT NULL (`spending_anomaly`, `limit_warning`, `due_date_reminder`, `goal_milestone`, `insight_summary`) |
| `title` | TEXT | NOT NULL |
| `message` | TEXT | NOT NULL |
| `severity` | TEXT | NOT NULL (`info`, `warning`, `critical`) |
| `is_read` | BOOLEAN | default `false` |
| `data` | JSONB | nullable (contextual data, e.g., `{category: "food", increase_pct: 25}`) |
| `created_at` | TIMESTAMPTZ | default `now()` |

---

### RecurrenceRule
| Field | Type | Constraints |
|-------|------|------------|
| `id` | UUID | PK |
| `user_id` | UUID | FK → users.id, NOT NULL |
| `frequency` | TEXT | NOT NULL (`daily`, `weekly`, `monthly`, `yearly`) |
| `interval` | INTEGER | default 1 |
| `day_of_month` | INTEGER | nullable, CHECK 1-31 |
| `day_of_week` | INTEGER | nullable, CHECK 0-6 |
| `end_type` | TEXT | NOT NULL default `'never'`, one of `'never'`, `'after_count'`, `'on_date'` |
| `end_count` | INTEGER | nullable (if end_type = 'after_count') |
| `end_date` | DATE | nullable (if end_type = 'on_date') |
| `next_occurrence` | DATE | nullable (pre-computed for efficiency) |
| `is_active` | BOOLEAN | default `true` |
| `created_at` | TIMESTAMPTZ | default `now()` |

---

## SQL Indexes (Performance)

```sql
-- User scoping indexes (every table)
CREATE INDEX idx_cards_user_id ON cards(user_id);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_purchases_user_id ON purchases(user_id);
CREATE INDEX idx_installments_user_id ON installments(user_id);
CREATE INDEX idx_invoice_cycles_user_id ON invoice_cycles(user_id);
CREATE INDEX idx_debts_user_id ON debts(user_id);
CREATE INDEX idx_goals_user_id ON goals(user_id);

-- Relationship indexes
CREATE INDEX idx_purchases_card_id ON purchases(card_id);
CREATE INDEX idx_installments_purchase_id ON installments(purchase_id);
CREATE INDEX idx_installments_invoice_cycle_id ON installments(invoice_cycle_id);
CREATE INDEX idx_invoice_cycles_card_id ON invoice_cycles(card_id);
CREATE INDEX idx_transactions_category_id ON transactions(category_id);
CREATE INDEX idx_receipts_transaction_id ON receipts(transaction_id);

-- Date-based queries (dashboard, calendar)
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_installments_due_date ON installments(due_date);
CREATE INDEX idx_invoice_cycles_due_date ON invoice_cycles(due_date);
CREATE INDEX idx_purchases_purchase_date ON purchases(purchase_date);
CREATE INDEX idx_financial_alerts_created ON financial_alerts(created_at DESC);
```

## RLS Policies (Template)

```sql
-- Example for cards table
CREATE POLICY "Users can view their own cards"
  ON cards FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own cards"
  ON cards FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own cards"
  ON cards FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own cards"
  ON cards FOR DELETE
  USING (auth.uid() = user_id);
```

Apply the same 4-policy pattern to all user-scoped tables.
