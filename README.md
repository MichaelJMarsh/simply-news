# Simply News

A **Flutter-based** mobile app that fetches news from [NewsAPI.org](https://newsapi.org) and displays them in a clear, text-focused interface. This project is part of a Headspace Mobile Engineering sample assignment.

---

## Table of Contents

- [Simply News](#simply-news)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Project Structure](#project-structure)
  - [Prerequisites](#prerequisites)
  - [Setup \& Installation](#setup--installation)

---

## Features

1. **Text-Only News Display**: Simplified, text-focused UI for reading articles.
2. **Save Articles**: “Save” or “Favorite” icon allows users to store articles locally (e.g. using SQLite).
3. **Auto-Refresh**: Periodic background refresh fetches the latest headlines.
4. **Unit Testing**: Basic test coverage for core business logic.

---

## Project Structure

A high-level overview of how the code is organized (folders may vary based on personal preference):

lib/
├── main.dart # App entry point
├── data/ # Data sources, models, API clients
├── ui/ # Presentation layer (Widgets, Screens)
├── services/ # Background services, refresh logic
└── utils/ # Helper methods, constants
test/ # Unit tests
pubspec.yaml # Dependency configuration

---

## Prerequisites

- **Flutter SDK** (2.0+ recommended)
- **Dart** (comes bundled with Flutter)
- **Android Studio / Xcode** (depending on your target platform)
  - For Android emulation, ensure you have the latest **Android SDK** installed.
  - For iOS simulation, ensure you have **Xcode** 12+.

> **Note**: You will need a [NewsAPI.org](https://newsapi.org) API key. Usually this is provided via a config file or environment variable (e.g., `lib/.env` or stored in Dart code for the sample). Please remember to **safeguard** sensitive keys in production.

---

## Setup & Installation

1. **Clone or Download the Repository**

   ```bash
   git clone https://github.com/YourUser/SimplyNews.git
   cd SimplyNews

   2.	Install Dependencies
   ```

flutter pub get

This pulls in all required Dart and Flutter packages.

Android 1. Open an Android Emulator
• Via Android Studio: Open AVD Manager and run a virtual device.
• Or from CLI:

emulator -avd <YOUR_EMULATOR_NAME>

    2.	Run the App

flutter run

If multiple devices are connected/emulators running, specify the device:

flutter run -d emulator-5554

(Replace emulator-5554 with the actual device ID.)

iOS 1. iOS Simulator
• Launch Xcode and open the Simulator, or from the terminal:

open -a Simulator

    2.	Run the App

flutter run

If you have multiple devices, specify the iOS simulator device:

flutter run -d <device_id>

(e.g., flutter run -d iPhone-13)

    Important: Make sure you have CocoaPods installed (sudo gem install cocoapods) and that your Xcode command-line tools are correctly configured for iOS builds.

Usage 1. Launching
Once the app is running, you will see a list of news articles. 2. Reading Articles
Tap on an article to view its details in a clean, text-based format. 3. Saving Articles
Tap the “Save”/“Favorite” icon on any article. This will store it in the local database. 4. Auto Refresh
The app periodically fetches fresh content in the background. You can also perform manual refresh if implemented (e.g., pull to refresh).

Testing
• Unit Tests are located in the test/ directory.
• Run tests via:

flutter test

    •	Any integration or widget tests (if included) can be similarly run with the same command, depending on the test suite organization.

Additional Notes
• This sample follows a minimal styling approach to match the requirement for a clean, text-only format.
• The background service/worker logic can vary between platforms. For simplicity, a background process or a timer-based approach might be used here.
• For production usage, consider secure storage solutions for API keys, user preferences, and offline data.

Thank you for reviewing Simply News!
Please reach out with any questions or suggestions you might have.
