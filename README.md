![WhatsApp Image 2026-03-31 at 10 58 28 AM (1)](https://github.com/user-attachments/assets/ce167942-d892-4021-b267-fce9ae19ee5b)# ✨ Smart Habit Coach

A beautifully designed, AI-powered habit tracking app built with Flutter — supporting Android, iOS, macOS, Windows, and Linux.

---

## 📱 Screenshots

 ![WhatsApp Image 2026-03-31 at 10 58 28 AM](https://github.com/user-attachments/assets/52bf798c-7a18-4180-809b-f0220f2f0769)
![WhatsApp Image 2026-03-31 at 10 58 28 AM (2)](https://github.com/user-attachments/assets/c1b118de-2b0d-4631-accf-9ff2953b28d5)
![WhatsApp Image 2026-03-31 at 10 58 28 AM (1)](https://github.com/user-attachments/assets/c02ccc99-c1aa-4cf7-bacf-434b776f6496)

---

## 🚀 Features

- **Habit Management** — Create, edit, and delete daily or weekly habits with custom emoji icons
- **Streak Tracking** — Automatic streak calculation with Bronze 🥉, Silver 🥈, and Gold 🥇 milestones
- **Smart Insights** — AI-powered suggestions based on your historical completion patterns (e.g., "You usually complete this at 8:00 PM")
- **Analytics Dashboard** — Weekly bar charts, completion rates, and per-habit performance breakdowns
- **Local Notifications** — Scheduled reminders via `flutter_local_notifications` with exact alarm support on Android
- **Dark / Light Theme** — Fully themed UI with persistent theme preference
- **Firebase Backend** — Real-time Firestore sync, Firebase Authentication (email/password), and password reset
- **Offline-Resilient** — Graceful fallback when Firestore is unreachable; auth always succeeds from Firebase Auth state
- **Animated UI** — Smooth fade, slide, and scale transitions throughout

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart SDK ≥ 3.0) |
| State Management | Provider 6 |
| Auth | Firebase Auth 5 |
| Database | Cloud Firestore 5 |
| Notifications | flutter_local_notifications 19 |
| Charts | fl_chart 0.66 |
| Fonts | Google Fonts (Sora + Inter) |
| Animations | Lottie |
| Storage | shared_preferences |
| Utilities | intl, uuid, timezone |

---

## 📂 Project Structure

```
lib/
├── main.dart                        # App entry point, Firebase init, providers
├── firebase_options.dart            # FlutterFire generated config
│
├── models/
│   ├── habit_model.dart             # HabitModel with streak, completion logic
│   └── user_model.dart              # UserModel with Firestore serialization
│
├── providers/
│   ├── auth_provider.dart           # Auth state management
│   ├── habit_provider.dart          # Habit CRUD + real-time stream
│   └── theme_provider.dart          # Dark/light theme persistence
│
├── screens/
│   ├── splash_screen.dart           # Animated splash + auth routing
│   ├── login_screen.dart            # Email/password sign-in
│   ├── register_screen.dart         # Account creation
│   ├── home_screen.dart             # Habit list, progress banner, tabs
│   ├── add_edit_habit_screen.dart   # Habit form (create / edit)
│   └── analytics_screen.dart        # Weekly chart + performance breakdown
│
├── components/
│   ├── habit_card.dart              # Swipeable habit card with animations
│   ├── custom_button.dart           # Gradient / outlined button
│   ├── custom_textfield.dart        # Styled form input
│   ├── loading_indicator.dart       # Pulsing loading widget
│   ├── empty_state_widget.dart      # Empty state placeholder
│   └── app_constants.dart           # App-wide constants
│
├── firebase auth/
│   ├── ai_service.dart              # Firebase Auth wrapper
│   ├── auth_service.dart            # Firebase Auth wrapper
│   ├── habit_service.dart           # Firestore CRUD + analytics
│   └── notification_service.dart    # Notification scheduling
│
├── providers/
│   └── theme_provider.dart
│
├── theme/
│   └── app_theme.dart               # Full Material 3 light + dark theme
│
└── utility helpers/
    └── data_utils.dart              # Date math, streak calc, greeting, etc.

test/
├── widget_test.dart                 # Basic smoke tests
├── habit_model_test.dart            # Unit tests for HabitModel
└── date_utils_test.dart             # Unit tests for AppDateUtils
```

---

## ⚙️ Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.27.0
- Dart SDK ≥ 3.0.0
- A Firebase project ([console.firebase.google.com](https://console.firebase.google.com))
- Android `minSdk` 23+ (required by Firebase Auth v5)

### 1. Clone the repository

```bash
git clone https://github.com/your-username/smart-habit-coach.git
cd smart-habit-coach
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

This project uses FlutterFire. To connect your own Firebase project:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will generate `lib/firebase_options.dart` and the platform config files (`google-services.json`, `GoogleService-Info.plist`).

> **Note:** The existing `lib/firebase_options.dart` and `android/app/google-services.json` are pre-configured for the `habit-smartcoach` project. Replace them with your own for production use.

### 4. Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 5. Run the app

```bash
# Android / iOS
flutter run

# Specific platform
flutter run -d android
flutter run -d ios
flutter run -d macos
flutter run -d windows
```

---

## 🔒 Firestore Security Rules

Habits and user documents are fully protected — only the authenticated owner can read or write their own data. Habit creation and updates are validated server-side:

- `title`: 2–50 characters (required)
- `frequency`: must be `"daily"` or `"weekly"`
- `description`: max 200 characters (optional)

See [`firestore.rules`](firestore.rules) for the full ruleset.

---

## 🔔 Notifications

Notification permissions are requested on first launch. Habit reminders are scheduled using exact alarms and persist across reboots via the `BOOT_COMPLETED` receiver.

**Required Android permissions (already declared in `AndroidManifest.xml`):**

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

---

## 🧪 Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Analyze code
flutter analyze
```

The test suite covers:

- `HabitModel` — `isCompletedToday`, `smartTimeSuggestion`, `streakLabel`, `completionRateThisWeek`, `copyWith`, serialization
- `AppDateUtils` — `isSameDay`, `isToday`, `isYesterday`, `calculateStreak`, `calculateCompletionRate`, `timeAgo`, `getLast7Days`

---

## 🎨 Theme & Design System

The app uses **Material 3** with two custom themes defined in `lib/theme/app_theme.dart`.

| Token | Light | Dark |
|---|---|---|
| Primary | `#6C63FF` | `#9C94FF` |
| Accent | `#00D9A3` | `#00D9A3` |
| Background | `#F8F7FF` | `#0F0E1A` |
| Card | `#FFFFFF` | `#231F3A` |
| Error | `#FF5A7E` | `#FF5A7E` |
| Success | `#00D9A3` | `#00D9A3` |

Fonts: **Sora** (headings) + **Inter** (body)

---

## 📦 Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release
```

---

## 🗺️ Roadmap

- [ ] Google Sign-In support
- [ ] Weekly / monthly goal targets per habit
- [ ] Habit categories and tags
- [ ] Cloud backup export (CSV / JSON)
- [ ] Widget support (Android & iOS)
- [ ] Collaborative habits (shared streaks)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'Add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

Please run `flutter analyze` and `flutter test` before submitting.

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 👤 Author

**buxhiisd**  
Bundle ID: `com.buxhiisd.smartHabitCoach`

---

> Built with ❤️ using Flutter & Firebase
