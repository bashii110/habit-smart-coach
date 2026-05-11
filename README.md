<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Windows-lightgrey?style=for-the-badge"/>
<img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Release-v1.0.0-6C63FF?style=for-the-badge"/>

<br/><br/>

# ✨ Smart Habit Coach

**An AI-powered habit tracking app — beautifully designed, cross-platform, and built with Flutter.**  
Track your habits, visualize your progress, and let smart insights guide you to consistency.

<br/>

[📥 Download APK](https://github.com/bashii110/habit-smart-coach/releases/download/v1.0.0/app-release.apk) &nbsp;·&nbsp;
[💼 LinkedIn](https://www.linkedin.com/in/bashir-ahmed110) &nbsp;·&nbsp;
[🐙 GitHub](https://github.com/bashii110) &nbsp;·&nbsp;
[🌐 Portfolio](https://bashii110.github.io/bashir_ahmed_portfolio/) &nbsp;·&nbsp;
[📬 Contact](mailto:buxhiisd@gmail.com)

</div>

---

## 📱 Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/52bf798c-7a18-4180-809b-f0220f2f0769" width="20%" />
  &nbsp;
  <img src="https://github.com/user-attachments/assets/c1b118de-2b0d-4631-accf-9ff2953b28d5" width="20%" />
  &nbsp;
  <img src="https://github.com/user-attachments/assets/c02ccc99-c1aa-4cf7-bacf-434b776f6496" width="20%" />
</p>

---

## 🚀 Features

| Feature | Description |
|---|---|
| 🗂️ **Habit Management** | Create, edit, and delete daily or weekly habits with custom emoji icons |
| 🔥 **Streak Tracking** | Auto streak calculation with 🥉 Bronze, 🥈 Silver, and 🥇 Gold milestones |
| 🤖 **Smart Insights** | AI-powered suggestions based on your historical completion patterns |
| 📊 **Analytics Dashboard** | Weekly bar charts, completion rates, and per-habit performance breakdowns |
| 🔔 **Local Notifications** | Scheduled reminders with exact alarm support, persistent across reboots |
| 🌙 **Dark / Light Theme** | Fully themed Material 3 UI with persistent theme preference |
| ☁️ **Firebase Backend** | Real-time Firestore sync + Firebase Authentication (email/password + password reset) |
| 📶 **Offline-Resilient** | Graceful fallback when Firestore is unreachable |
| 🎞️ **Animated UI** | Smooth fade, slide, and scale transitions throughout |

---

## 📥 Download & Install

> **Requires Android 6.0+ (minSdk 23)**

<div align="center">

[![Download APK](https://img.shields.io/badge/⬇️%20Download%20APK-v1.0.0-6C63FF?style=for-the-badge)](https://github.com/bashii110/habit-smart-coach/releases/download/v1.0.0/app-release.apk)

</div>

1. Tap the button above to download the `.apk` file
2. On your Android device, go to **Settings → Install unknown apps** and allow your browser
3. Open the downloaded file and tap **Install**
4. Launch **Smart Habit Coach** and sign up 🎉

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

## 🎨 Design System

The app uses **Material 3** with two custom themes defined in `lib/theme/app_theme.dart`.

| Token | Light | Dark |
|---|---|---|
| Primary | `#6C63FF` | `#9C94FF` |
| Accent | `#00D9A3` | `#00D9A3` |
| Background | `#F8F7FF` | `#0F0E1A` |
| Card | `#FFFFFF` | `#231F3A` |
| Error | `#FF5A7E` | `#FF5A7E` |

Fonts: **Sora** (headings) + **Inter** (body)

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
├── services/
│   ├── auth_service.dart            # Firebase Auth wrapper
│   ├── habit_service.dart           # Firestore CRUD + analytics
│   └── notification_service.dart    # Notification scheduling
│
├── theme/
│   └── app_theme.dart               # Full Material 3 light + dark theme
│
└── utils/
    └── data_utils.dart              # Date math, streak calc, greeting, etc.

test/
├── widget_test.dart                 # Basic smoke tests
├── habit_model_test.dart            # Unit tests for HabitModel
└── date_utils_test.dart             # Unit tests for AppDateUtils
```

---

## ⚙️ Getting Started (Build from Source)

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.27.0
- Dart SDK ≥ 3.0.0
- A Firebase project ([console.firebase.google.com](https://console.firebase.google.com))
- Android `minSdk` 23+

### 1. Clone the repository

```bash
git clone https://github.com/bashii110/habit-smart-coach.git
cd habit-smart-coach
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` and platform config files.

### 4. Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 5. Run the app

```bash
flutter run              # Android / iOS
flutter run -d macos     # macOS
flutter run -d windows   # Windows
```

---

## 🔒 Firestore Security Rules

Only the authenticated owner can read or write their own data. Server-side validation enforces:

- `title`: 2–50 characters (required)
- `frequency`: `"daily"` or `"weekly"` only
- `description`: max 200 characters (optional)

---

## 🔔 Notifications

Reminders are scheduled using exact alarms and persist across reboots via `BOOT_COMPLETED`.

**Required Android permissions (declared in `AndroidManifest.xml`):**

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

---

## 🧪 Running Tests

```bash
flutter test              # All tests
flutter test --coverage   # With coverage
flutter analyze           # Static analysis
```

Test coverage includes `HabitModel`, `AppDateUtils`, and widget smoke tests.

---

## 📦 Build

```bash
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android App Bundle (Play Store)
flutter build ios --release          # iOS (requires macOS + Xcode)
flutter build macos --release        # macOS
flutter build windows --release      # Windows
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

## 👤 Author

<div align="center">

**Bashir Ahmed** — Flutter Developer  
Software Engineering Student @ Quaid e Awam University, Nawabshah (2026)

<br/>

[![LinkedIn](https://img.shields.io/badge/LinkedIn-bashir--ahmed110-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/bashir-ahmed110)
[![GitHub](https://img.shields.io/badge/GitHub-bashii110-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/bashii110)
[![Portfolio](https://img.shields.io/badge/Portfolio-Visit-6C63FF?style=for-the-badge&logo=firefox&logoColor=white)](https://bashii110.github.io/bashir_ahmed_portfolio/)
[![Email](https://img.shields.io/badge/Email-buxhiisd@gmail.com-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:buxhiisd@gmail.com)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-Chat-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)](https://wa.me/923063440645)

</div>

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

Built with ❤️ and Flutter by **Bashir Ahmed**

⭐ Star this repo if you found it helpful!

</div>
