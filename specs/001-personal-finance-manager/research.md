# Research & Technical Decisions

## 1. Chart Library: FL Chart

- **Decision**: FL Chart (fl_chart)
- **Rationale**: MIT licensed (free), supports all required chart types (pie, bar, line, radar), native Flutter animations via `duration`/`curve`, good performance for personal finance data volume (hundreds to thousands of points), massive adoption in Brazilian developer community with abundant Portuguese documentation. Syncfusion requires ~$995/dev/year commercial license and its community license has revenue/team restrictions.
- **Alternatives considered**: Syncfusion Flutter Charts (enterprise-grade but costly), Graphic (grammar-based, steeper learning curve), flutter_echarts (WebView-based, heavier).

## 2. OCR Approach: Google ML Kit + Client-side PDF Parsing

- **Decision**: Google ML Kit (on-device) for receipt photos; client-side Dart PDF text extraction for invoice PDFs
- **Rationale**: ML Kit supports Brazilian Portuguese (full Latin charset), works offline (free benefit), zero cost. Invoice PDFs from major Brazilian banks (Nubank, Inter, Itaú, Bradesco, Santander) are text-based digital PDFs — no OCR needed, use `syncfusion_flutter_pdf` or `pdf_text_extraction` for text extraction + regex parsing. Cloud OCR adds unnecessary latency, cost, and internet dependency.
- **Alternatives considered**: Google Cloud Vision API (better accuracy but paid + online-only), Tesseract (poor accuracy on real-world receipts), dedicated OCR APIs like Veryfi/Mindee (vendor lock-in, monthly fees).

## 3. State Management: Riverpod + Flutter Hooks

- **Decision**: Riverpod with code generation + Flutter Hooks
- **Rationale**: Riverpod provides compile-time safety, testability without widget tree dependency, and native StreamProvider support for reactive Drift/SQLite streams. Flutter Hooks reduces boilerplate for animation controllers, text editing controllers, and lifecycle management. The combination is idiomatic Flutter and widely adopted in Brazilian development community.
- **Alternatives considered**: BLoC (more boilerplate, less reactive), Provider (less safe, deprecated in favor of Riverpod), GetX (all-in-one but controversial in community).

## 4. Offline-First Strategy: Drift (SQLite) + Manual Sync Layer

- **Decision**: Drift (formerly Moor) as local SQLite database with manual sync service (~150 lines). Read from Drift first (instant), fetch Supabase in background, update via Riverpod StreamProviders. Writes go to Drift first (optimistic), sync to Supabase. Last-write-wins with `updated_at` timestamps.
- **Rationale**: Single-user app → no real sync conflicts. Drift exposes Stream<List<T>> → perfect for Riverpod StreamProvider reactivity. Manual sync layer is transparent and manually verifiable (constitution requirement). Brazilian connectivity is unreliable (3G dead zones, subway) — offline-first prevents blank screens.
- **Alternatives considered**: Brick (heavy code generation, opaque sync logic), PowerSync (paid, overkill for single-user), Hive (key-value, not relational), no offline cache (user churn).

## 5. Supabase Row Level Security (RLS)

- **Decision**: Each table has `user_id` FK from `auth.users.id`. One permissive RLS policy per CRUD operation using `auth.uid() = user_id`. Optionally a reusable `is_own_row()` helper function. Edge Functions use user's JWT (not service_role) except for cron jobs.
- **Rationale**: Simplest correct solution for single-user app. RLS enforces data isolation at DB level even if anon key is compromised. Service_role bypass for cron-triggered functions (generate-insights) with explicit `user_id` filtering in SQL.
- **Alternatives considered**: Multi-tenant RLS with tenant_id (future scope), no RLS (error-prone app-layer auth), service_role everywhere (defeats RLS purpose).

## 6. Supabase Edge Functions

- **Decision**: Four Edge Functions:

| Function | Trigger | Purpose |
|----------|---------|---------|
| `generate-insights` | Cron (weekly Sun 20:00) + on-demand | AI spending analysis, anomaly detection, invoice prediction |
| `reconcile-invoice` | On-demand (user uploads invoice) | Compare invoice line items vs registered purchases |
| `process-receipt-ocr` | On-demand (user uploads receipt) | Extract merchant, value, date, category from receipt image/PDF |
| `classify-transaction` | On-demand (user adds transaction) | Suggest category based on merchant, value, past transactions |

- **Rationale**: Each function has single responsibility (constitution). OCR and AI require server-side libs not available in Dart. Running server-side protects API keys (OpenAI key never exposed to client). 10s timeout and 150MB memory are sufficient for single-page documents.
- **Alternatives considered**: Monolithic "ai-service" function (SRP violation), client-side AI (key exposure), pg_cron in Postgres (can't call OpenAI APIs), no Edge Functions (missed features).

## 7. UI/UX Framework Choices

- **Decision**: Material 3 with responsive breakpoints (phone/tablet/desktop), Lottie for onboarding animations, custom glassmorphism widgets in `shared/widgets/`
- **Rationale**: Material 3 is the standard Flutter design language with built-in responsive support. Lottie provides lightweight, performant animations. Glassmorphism is achieved with `BackdropFilter` + `ClipRRect` — no additional dependency needed. Dark mode is built into Material 3 theming.
- **Alternatives considered**: Cupertino (iOS-only feel), custom design system (excessive effort for v1).

## 8. Navigation: GoRouter

- **Decision**: GoRouter with ShellRoute for bottom navigation, nested routes per feature, deep linking support
- **Rationale**: GoRouter is the officially recommended Flutter router, supports declarative routing, `ShellRoute` for persistent bottom nav, redirect guards for auth, and deep linking. Feature-first routing aligns with project structure.
- **Alternatives considered**: Navigator 2.0 raw API (too verbose), auto_route (code generation overhead), Beamer (less active maintenance).

## 9. Push Notifications: Firebase Cloud Messaging (FCM)

- **Decision**: Firebase Cloud Messaging via `firebase_messaging` Flutter package, with local notification fallback for offline alerts
- **Rationale**: FCM is the standard cross-platform push notification solution. Integration with Supabase Edge Functions via HTTP v1 API allows server-triggered notifications (limit warnings, invoice reminders, insight alerts). Local notifications via `flutter_local_notifications` for offline-generated alerts.
- **Alternatives considered**: OneSignal (third-party, adds cost), custom WebSocket (overkill for notifications).

## 10. AI Integration: OpenAI API

- **Decision**: GPT-4o-mini via Edge Functions for: spending insights, anomaly detection, invoice prediction, transaction classification. No client-side AI.
- **Rationale**: GPT-4o-mini is cost-effective ($0.15/1M input tokens), fast, and sufficient for structured financial text analysis. All AI calls go through Edge Functions to protect the API key. Responses are cached and rate-limited per user. Insights are generated weekly (cron) + on-demand, not per-transaction.
- **Alternatives considered**: Anthropic Claude (comparable cost, less common in Brazilian dev ecosystem), local ML models (excessive complexity for v1), rule-based insights (no learning, poor anomaly detection).
