# Simply News

A **Flutter** app that fetches headlines from [NewsAPI.org](https://newsapi.org) and displays them in a clean, text-focused interface. Built as part of a Headspace Mobile Engineering sample assignment.

---

## Features

1. **Text-Only News** – Minimalist news reading experience
2. **Save / Favorite Articles** – Local storage (e.g., SQLite) for saved headlines
3. **Auto-Refresh** – Background service to keep news up-to-date
4. **Unit Testing** – Basic coverage for core business logic

---

## Project Structure

lib/
├── main.dart # App entry point
├── data/ # Data sources, models, API clients
├── ui/ # Presentation layer (Widgets, Screens)
├── services/ # Background tasks, refresh logic
└── utils/ # Helper methods, constants
test/ # Unit tests
pubspec.yaml # Dependency configuration

---

## Prerequisites

- **Flutter SDK** (2.0+)
- **Dart** (included with Flutter)
- **Android Studio** or **Xcode** (for emulators/simulators)
- **NewsAPI.org** API key (store securely in real-world scenarios)

> **Note**: Make sure to secure API keys (e.g., via `.env` or other methods) if deploying to production.

---

## Setup & Installation

1. **Clone or Download** this repository:

   ```bash
   git clone https://github.com/YourUser/SimplyNews.git
   cd SimplyNews

   2.	Install Dependencies:
   ```

flutter pub get

    3.	Run the App:
    •	Android
    •	Launch an emulator (AVD Manager in Android Studio)
    •	Run:

flutter run

    •	If multiple devices/emulators are connected, specify a device:

flutter run -d emulator-5554

    •	iOS
    •	Launch the iOS Simulator (via Xcode or CLI):

open -a Simulator

    •	Run:

flutter run

    •	To specify a device:

flutter run -d iPhone-13

Usage 1. Launch the app to view the latest articles. 2. Tap an article to read a text-focused view. 3. Save (favorite) the article locally with the “Save” icon. 4. Refresh is automatic via a background service or can be triggered manually (if pull-to-refresh is implemented).

Testing
• Unit Tests are located in test/.
• Run tests with:

flutter test

Thank you for exploring Simply News!
Feel free to reach out with any questions or suggestions.
