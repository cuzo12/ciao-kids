# Ciao Kids 🇮🇹

An AI-powered Italian language tutor for children ages 5–15. Instead of
worksheets, kids *talk* with friendly Italian characters who listen, respond,
and gently coach pronunciation.

This repository is being built **one milestone at a time**. The section below
tracks scope; everything currently in `lib/` belongs to **Milestone 1**.

---

## Milestone status

| # | Milestone | Status |
|---|-----------|--------|
| 1 | Project setup, architecture, navigation, login + home | ✅ Done |
| 2 | Lesson engine (intro → vocab → pronunciation → match → quiz → review) + progress, rewards & unlocks | ✅ Done |
| 3 | AI conversation + on-device speech (scripted tutor; TTS + STT) | ✅ Done |
| 4 | Pronunciation coach (speech scoring + syllable practice) | ✅ Done |
| 5 | Rewards: badges/achievements, virtual passport, unlockable cities | ✅ Done |
| 6 | Story mode (branching, voice-driven) | ✅ Done |
| 7 | Parent dashboard + practice-stats tracking (parent-gated) | ✅ Done |
| 8 | Cloud auth (Firebase) + parent accounts & profiles | ⛔ Needs your Firebase project* |
| 9 | Claude-backed conversation (open-ended, server-proxied) | ⛔ Needs #8* |

The whole app runs **today, fully offline** with local auth, a deterministic
child-safe scripted tutor, on-device speech, and local progress/stats storage.

\* The two remaining items need infrastructure only you can provision:
- **#8 Cloud auth** requires a Firebase project (created in your Google console)
  and the FlutterFire CLI. The local auth store already sits behind the
  `AuthRepository` interface, so it swaps in without touching the app.
- **#9 Claude-backed conversation** implements the existing `AiTutorEngine`
  interface via a Cloud Functions proxy (so it depends on #8) and needs an
  Anthropic API key. It never ships a key in the client; the scripted engine
  remains the safe fallback.

---

## Getting started

### 1. Install the Flutter SDK

Flutter is **not yet installed** on this machine. Install it once:

- Download: <https://docs.flutter.dev/get-started/install/windows>
- Or via winget: `winget install --id=Google.Flutter -e`
- Then verify: `flutter doctor`

### 2. Generate the native platform folders

This repo intentionally ships only the cross-platform Dart code (`lib/`,
`pubspec.yaml`, `test/`). Run this **once** in the project root to add the
`android/`, `ios/`, `web/`, and other platform scaffolding without touching the
existing code:

```bash
flutter create --org com.ciaokids --project-name ciao_kids .
```

`flutter create` never overwrites files that already exist, so your `lib/` and
`pubspec.yaml` are preserved.

### 3. Run it

```bash
flutter pub get
flutter run         # pick a device/emulator
flutter test        # run the unit + widget tests
```

> **Try it instantly:** on the login screen, tap **Continue as guest** — no
> account needed. Or **Create an account** to register a learner profile that
> persists across launches.

### 4. Enable speech (microphone & voice)

The tutor speaks (TTS) and listens (STT) on-device. TTS works out of the box;
**microphone input needs platform permissions** added to the generated native
folders. Without them the app still works — it falls back to suggestion chips
and typed input — but the mic button won't appear.

**Android** — in `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<queries>
  <intent><action android:name="android.speech.RecognitionService" /></intent>
  <intent><action android:name="android.intent.action.TTS_SERVICE" /></intent>
</queries>
```

**iOS** — in `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Ciao Kids listens so your child can practice speaking Italian.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Ciao Kids uses speech recognition to coach pronunciation.</string>
```

Then on the home screen tap **Practice Talking 💬** to chat with a character.

---

## Architecture

Ciao Kids uses **feature-first clean architecture**. Each feature is a vertical
slice split into three layers, with dependencies pointing strictly inward
(`presentation → domain ← data`):

```
lib/
├── main.dart                 # Entry point: init DI, run the app
├── app/
│   ├── app.dart              # Root MaterialApp.router + theming
│   └── di/service_locator.dart  # get_it dependency graph
├── core/                     # Cross-cutting, feature-agnostic building blocks
│   ├── constants/            # App-wide constants & persistence keys
│   ├── errors/               # Exceptions (data) + Failures (domain)
│   ├── result/               # Result<T> = Success | ResultError
│   ├── router/               # go_router config + route constants
│   ├── theme/                # Colors, typography, spacing, ThemeData
│   └── utils/                # Validators, responsive helpers
├── features/
│   ├── auth/
│   │   ├── domain/           # Entities, repository CONTRACTS, use cases
│   │   ├── data/             # Models, datasources, repository IMPLEMENTATIONS
│   │   └── presentation/     # Controllers (state) + screens + widgets
│   ├── home/                 # Dashboard shell
│   └── splash/               # Session-restore loading screen
└── shared/
    └── widgets/              # Reusable UI primitives (button, text field, …)
```

### Why these layers

- **Domain** is pure Dart — entities, use cases, and *abstract* repositories.
  It has zero knowledge of Flutter, Firebase, or storage. This is what makes the
  business rules testable and durable.
- **Data** implements the domain's repository contracts and translates
  low-level `AppException`s into safe, child-friendly `Failure`s.
- **Presentation** holds `ChangeNotifier` controllers (the "business logic" the
  UI binds to) and the widgets themselves. Screens never construct
  repositories — they ask the controller, which was built by the DI container.

### Key decisions (Milestone 1)

| Concern | Choice | Rationale |
|---------|--------|-----------|
| State management | `provider` + `ChangeNotifier` | Minimal, explicit, easy to test; controllers stay framework-light |
| Navigation | `go_router` | Declarative, URL-based, with a single auth-aware redirect guard |
| Dependency injection | `get_it` | Keeps construction out of the UI; one-line swap from local → Firebase |
| Error handling | `Result<T>` (no throwing across layers) | Forces the UI to handle both success and failure paths |
| Auth (this milestone) | Local `shared_preferences` store, salted+hashed passwords | Fully working end-to-end **today**; replaced by Firebase Auth behind the same `AuthRepository` interface in Milestone 2 |
| Theming | Centralized tokens + Material 3 | Consistent kid-friendly look; light **and** dark mode included |

### The auth flow

```
LoginScreen ─▶ AuthController ─▶ SignIn (use case) ─▶ AuthRepository
                   │                                       │
                   │                                  AuthRepositoryImpl
                   ▼                                       │
              (notifies)                            AuthLocalDataSource
                   │                                       │
                   ▼                                shared_preferences
            go_router redirect ─▶ HomeScreen / LoginScreen
```

The router observes `AuthController` via `refreshListenable`; whenever auth
state changes, navigation guards re-run automatically. Screens never push
`/home` themselves.

---

## Conventions

- **Every class is documented** (`///`) per the project rules.
- No placeholder logic — the local auth store is a real, working implementation.
- Design values (color, spacing, type) live in `core/theme`, never inline.
- Lint rules: see `analysis_options.yaml` (extends `flutter_lints`).
