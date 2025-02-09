# Simply News

A **Flutter** app that fetches headlines from [NewsAPI.org](https://newsapi.org) and displays them in a clean, text-focused interface. Built as part of a Headspace Mobile Engineering sample assignment.

---

## Features

1. **Text-Only News** – Minimalist news reading experience.
2. **Save / Favorite Articles** – Local storage (e.g., SQLite) for saved headlines.
3. **Auto-Refresh** – Background service to keep news up-to-date.
4. **Testing** – Basic coverage for core business logic and widgets.

---

## Project Structure

This project follows the **Clean Architecture** pattern, separating concerns into **Data**, **Domain**, and **UI** layers for better scalability and maintainability.

```plaintext
android/              # Android-specific code
build/                # Generated files
ios/                  # iOS-specific code
lib/                  # Main source code
├── pages/            # Screens and UI pages
├── widgets/          # Reusable UI components
├── app_theme.dart    # App-wide theme configuration
├── app.dart          # Root app widget
├── bootstrap.dart    # Initialization logic
├── firebase_options.dart # Firebase configuration
├── main.dart         # App entry point
├── runner.dart       # App bootstrapper
packages/             # Internal modular packages
├── data/             # Data sources (API clients, local storage, plugins)
├── domain/           # Business logic, models, repositories, services
test/                 # Unit and widget tests
pubspec.yaml          # Dependency configuration
README.md             # Documentation
```

---

## Prerequisites

- Flutter SDK (version 3.27.4)
- Dart (included with Flutter)
- Android Studio or Xcode (for emulators/simulators)
- NewsAPI.org API key (store securely in real-world scenarios)

**Note:** The API key is fetched from Firebase Remote Config. You can use the current setup if there are still free API calls remaining. Otherwise, add your own [NewsAPI.org](https://newsapi.org) API key manually by updating the following line in `lib/bootstrap.dart`:

```bash
NewsArticlePlugin(apiKey: "YOUR_NEWSAPI_KEY")
```

---

## Setup & Installation

1. Clone or Download this repository:

```bash
git clone https://github.com/MichaelJMarsh/simply-news.git
cd simply_news
```

2. Install Dependencies:

```bash
flutter pub get
```

3. Run the App:

#### Android

- Launch an emulator (using AVD Manager in Android Studio)
- Run:

```bash
flutter run
```

- If multiple devices/emulators are connected, specify a device:

```bash
flutter run -d emulator-5554
```

#### iOS

- Launch the iOS Simulator (via Xcode or CLI):

```bash
open -a Simulator
```

- Run:

```bash
flutter run
```

- To specify a device:

```bash
flutter run -d iPhone-13
```

---

## Usage

1. **Launch the app** to view the latest articles on the **dashboard**.
2. **Tap an article** to read a **text-focused** view.
3. **Save (favorite) an article** locally by tapping the **"ADD TO FAVORITES"** floating action button or **favorite icon**.
4. **Access saved articles** anytime by navigating to the **Favorites Page**.
5. **Scroll down on the dashboard** to load more articles via **paginated scrolling** (new articles load until no more are available).
6. **Enjoy automatic refresh** via the background service, or manually trigger a refresh by pulling down from the top of the dashboard.

---

## Testing

- Unit tests are located in the `test/` directory.
- Run tests with:

```bash
flutter test
```

Thank you for taking the time to explore Simply News!
