<div align="center">
  <img src="assets/icon.png" alt="EspritSphere Logo" width="120"/>
  <h1>EspritSphere</h1>
  <p><strong>University Events, Clubs & Movies – Flutter Application</strong></p>

  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
  ![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
  ![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20Storage-FFCA28?logo=firebase)
  ![License](https://img.shields.io/badge/License-MIT-green)
</div>

---

## Table of Contents

- [About the Project](#about-the-project)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Firebase Setup](#firebase-setup)
  - [Environment Configuration](#environment-configuration)
  - [Running the App](#running-the-app)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

---

## About the Project

**EspritSphere** is a cross-platform mobile and web application built for Esprit University students and staff. It provides a centralised hub for:

- Discovering and booking seats for **movies** screened on campus
- Joining and managing **student clubs**
- Creating and attending **university events**
- Viewing personal **reservations** and profile statistics

The app targets Android, iOS, and Web from a single Dart/Flutter codebase and uses Firebase as its backend (Firestore, Authentication, Storage).

---

## Features

| Area | Capabilities |
|------|-------------|
| **Authentication** | Email/password sign-up with email verification, login, password reset |
| **Movies** | Browse movie feed, watch trailers (YouTube), reserve seats with a seat-map |
| **Clubs** | Browse and join student clubs, club detail pages |
| **Events** | Browse, create and manage university events |
| **Reservations** | View all personal reservations, cancel bookings |
| **Profile** | User profile, edit details, view statistics |
| **Admin Dashboard** | Manage movies, clubs, events and users (admin role) |
| **Theming** | Light / dark mode toggle |
| **Onboarding** | Animated splash screen and multi-step onboarding flow |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | [Flutter](https://flutter.dev) (Dart) |
| State Management | [Provider](https://pub.dev/packages/provider) |
| Backend / Auth | [Firebase Auth](https://firebase.google.com/products/auth) |
| Database | [Cloud Firestore](https://firebase.google.com/products/firestore) |
| Storage | [Firebase Storage](https://firebase.google.com/products/storage) |
| Video | [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter) |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) |
| QR Codes | [qr_flutter](https://pub.dev/packages/qr_flutter) |
| In-App Browser | [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) |

---

## Project Structure

```
lib/
├── main.dart               # App entry point & Firebase initialisation
├── app.dart                # Root widget, routing, theme provider
├── firebase_options.dart   # Firebase config (git-ignored – see Environment Configuration)
├── models/                 # Data models (User, Movie, Club, Event, Reservation)
├── screens/
│   ├── auth/               # Login, Sign-up, Verification, Reset Password
│   ├── boarding_pages/     # Splash & Onboarding screens
│   ├── home/               # Home screen with navigation drawer
│   ├── movies/             # Movie feed, detail, admin
│   ├── clubs/              # Club feed, detail, admin
│   ├── events/             # Event feed, detail, admin
│   ├── seats/              # Seat selection & booking
│   ├── profile/            # User profile & settings
│   ├── reservations/       # Personal reservations list
│   ├── stats/              # Statistics dashboard
│   └── chat/               # Messaging
├── services/
│   └── auth_service.dart   # Firebase Auth wrapper
└── utils/
    └── routes.dart         # Named route definitions

assets/
├── icon.png                # App icon
└── images/                 # Onboarding & placeholder images

android/app/
└── google-services.json    # Android Firebase config (git-ignored – see below)
```

---

## Getting Started

### Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter SDK | ≥ 3.8 | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| Dart SDK | ≥ 3.8 (bundled with Flutter) | — |
| Firebase CLI | latest | `npm install -g firebase-tools` |
| FlutterFire CLI | latest | `dart pub global activate flutterfire_cli` |
| Android Studio / Xcode | latest | Platform-specific |

### Firebase Setup

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Email/Password** authentication under *Authentication → Sign-in method*.
3. Create a **Firestore** database and set appropriate security rules.
4. Register your Android and/or iOS app inside the Firebase project.
5. Download the platform credentials:
   - **Android:** `google-services.json` → place at `android/app/google-services.json`
   - **iOS:** `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`
6. Run the FlutterFire CLI to regenerate `lib/firebase_options.dart`:
   ```bash
   flutterfire configure --project=<your-project-id>
   ```

### Environment Configuration

Credentials are **never stored in source control**. Instead they are injected at
build time via Dart's `--dart-define-from-file` flag.

```bash
# 1. Copy the example file
cp .env.example .env

# 2. Open .env and fill in your Firebase project values
#    (Firebase Console → Project Settings → Your apps)

# 3. Run or build with the env file
flutter run --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
flutter build web --dart-define-from-file=.env
```

> **⚠️ Important:** The `.env` file, `lib/firebase_options.dart`, and
> `android/app/google-services.json` are all listed in `.gitignore`.
> **Never commit these files.**

See `.env.example`, `lib/firebase_options.dart.example`, and
`android/app/google-services.json.example` for the expected structure.

### Running the App

```bash
# Install dependencies
flutter pub get

# Run on a connected device / emulator
flutter run --dart-define-from-file=.env

# Run on Chrome (web)
flutter run -d chrome --dart-define-from-file=.env

# Build release APK
flutter build apk --release --dart-define-from-file=.env
```

---

## Security

- **No credentials in source control.** API keys and Firebase configuration are
  supplied at build time via `--dart-define-from-file=.env` and are never committed.
- **Sensitive files are gitignored:** `.env`, `lib/firebase_options.dart`,
  `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist`.
- **Firebase Security Rules** should be configured in the Firebase Console to restrict
  read/write access to authenticated users only. Never deploy with open rules
  (`allow read, write: if true`).
- **Rotate compromised keys** immediately in the Firebase Console under
  *Project Settings → Service Accounts* and regenerate platform credentials.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Configure your local credentials (see [Environment Configuration](#environment-configuration))
4. Commit your changes: `git commit -m 'feat: add my feature'`
5. Push to the branch: `git push origin feature/my-feature`
6. Open a Pull Request

---
## Author && Acknowledgements 
Youssef Abbes Creator and Lead Developer

This project was developed to enhance the student experience at Esprit University, providing a modern solution for campus engagement and event management. Special thanks to the Flutter and Firebase communities for the robust tools that made this project possible.

GitHub: https://github.com/YoussefAbbes

## License

This project is licensed under the [MIT License](LICENSE).
