# Quickstart — Personal Finance Manager

## Prerequisites

- Flutter SDK 3.x
- Dart 3.x
- Supabase CLI
- Firebase CLI (for notifications)
- Node.js 18+ (for Edge Functions)

## Initial Setup

### 1. Create Flutter project

```bash
flutter create --org com.cardvalue --project-name cardvalue .
```

### 2. Install dependencies

```yaml
# pubspec.yaml key dependencies
dependencies:
  flutter:
    sdk: flutter
  # Navigation
  go_router: ^14.0.0
  
  # State management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  flutter_hooks: ^0.20.0
  hooks_riverpod: ^2.5.0
  
  # Backend
  supabase_flutter: ^2.5.0
  
  # Charts
  fl_chart: ^0.68.0
  
  # Local DB (offline)
  drift: ^2.19.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0
  
  # Animations
  lottie: ^3.1.0
  
  # UI
  responsive_framework: ^1.5.0
  
  # OCR
  google_mlkit_text_recognition: ^0.12.0
  
  # Storage / Security
  flutter_secure_storage: ^9.2.0
  image_picker: ^1.1.0
  file_picker: ^8.0.0
  
  # PDF
  syncfusion_flutter_pdf: ^27.0.0
  
  # Notifications
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.0
  flutter_local_notifications: ^17.2.0

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  drift_dev: ^2.19.0
```

### 3. Configure Supabase

```dart
// lib/services/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> configureSupabase() async {
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
}
```

### 4. Initialize Firebase

```dart
// lib/main.dart (partial)
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureSupabase();
  runApp(ProviderScope(child: CardValueApp()));
}
```

### 5. Run database migrations

```bash
supabase link --project-ref <project-ref>
supabase db push
```

### 6. Deploy Edge Functions

```bash
cd supabase/functions
supabase functions deploy generate-insights
supabase functions deploy reconcile-invoice
supabase functions deploy process-receipt-ocr
supabase functions deploy classify-transaction
```

## Project Bootstrap Checklist

- [ ] Flutter project created with `flutter create`
- [ ] Dependencies added to `pubspec.yaml`
- [ ] Supabase project created and configured
- [ ] Firebase project created (for FCM)
- [ ] Database migrations applied (tables, indexes, RLS)
- [ ] Edge Functions deployed
- [ ] Storage buckets created (`receipts`, `invoices`)
- [ ] Auth providers configured (email/password, Google, Apple)
- [ ] `flutter pub get` successful
- [ ] App runs on at least one platform

## Running the App

```bash
# Development
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>

# Web
flutter run -d chrome --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>

# iOS
flutter run -d ios --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>

# Android
flutter run -d android --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>
```

## Architecture Invariants

1. All database queries go through RLS — never use service_role from client
2. Drift is the source of truth for UI; Supabase is the source of truth for persistence
3. Edge Functions are single-responsibility — one function, one job
4. Features are self-contained — no cross-feature imports from `features/`
5. Shared code lives in `core/` or `shared/` — never duplicate across features
6. Every user action must be manually verified before commit (per constitution)
