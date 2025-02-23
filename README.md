# Simply News

A **Flutter** app that delivers **text-focused news** from [NewsAPI.org](https://newsapi.org) in a clean, minimalist interface. Developed for a Headspace Mobile Engineering assignment, this project follows clean architecture principles and demonstrates best practices in Flutter development, state management, and testing.

---

<img src="images/simply_news_mockups.png" alt="Simply News Mockups" width="100%">

---

## 📌 Features

- **Minimalist News Reader** – Enjoy a distraction-free, text-first browsing experience.
- **Save & Favorite Articles** – Easily store news items locally using **SQLite**.
- **Infinite Scrolling** – Seamlessly loads more articles as you browse.
- **Pull-to-Refresh** – Instantly fetch the latest headlines at any time.
- **Robust Testing** – Comprehensive unit & widget tests for core logic.

---

## 🏗 Project Structure

This project follows the **Clean Architecture** pattern, separating concerns into **Data**, **Domain**, and **UI** layers for better scalability and maintainability.

```plaintext
android/              # Android-specific code
build/                # Generated files
ios/                  # iOS-specific code
lib/                  # Main source code
├── config/           # Configuration files
├── presentation/     # UI-related code
│   ├── animations/
│   ├── pages/
│   ├── widgets/
├── app.dart          # Root app widget
├── bootstrap.dart    # Initialization logic
├── main.dart         # App entry point
├── launcher.dart     # Startup manager
packages/             # Internal modular packages
├── data/             # Data sources (API clients, local storage, plugins)
│   ├── lib/
│   │   ├── src/
│   │       ├── client/
│   │       ├── plugin/
│   │       ├── sqlite/
│   ├── test/
├── domain/           # Business logic, models, repositories, services
│   ├── lib/
│   │   ├── src/
│   │       ├── model/
│   │       ├── repository/
│   │       ├── service/
│   ├── test/
test/                 # Unit and widget tests for the lib directory
pubspec.yaml          # Dependency configuration
README.md             # Documentation
```

---

## 📋 Prerequisites

- Flutter SDK **version 3.29.0**
- Dart **version 3.7.0** (included with Flutter)
- Android Studio or Xcode (for emulators/simulators)
- [NewsAPI.org](https://newsapi.org) API key (securely stored in Firebase Remote Config)

**Note:** By default, the API key is fetched from Firebase Remote Config. If you exceed the free API limits, manually add your own key in `lib/bootstrap.dart`:

```bash
NewsArticleClient(apiKey: "YOUR_NEWSAPI_KEY")
```

---

## 🛠 Setup & Installation

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

## 📱 Usage

1. **Launch the app** to view the latest articles on the **dashboard**.
2. **Tap an article** to open a **text-focused** reading view.
3. **Save (favorite) an article** locally by tapping the **"ADD TO FAVORITES"** floating action button or the **favorite icon**.
4. **Access saved articles** anytime by navigating to the **Favorites Page**.
5. **Scroll down on the dashboard** to load more articles via **paginated scrolling** (new articles load until no more are available), ensuring a smooth and **performant** browsing experience.
6. **Stay updated** by manually pulling down from the top of the dashboard to fetch the latest news at your convenience!

---

## 🧪 Testing

All tests are organized under:

- `test/` (main app tests)
- `packages/data/test/`
- `packages/domain/test/`

Run all tests within a given package using:

```bash
flutter test
```

Or run everything at once using my custom script:

```bash
dart run_all_tests.dart
```

---

## 🙌 Thank you for taking the time to explore Simply News!

I built this project in just 24 hours as part of a Headspace Mobile Engineering assignment, demonstrating my ability to rapidly develop and refine a full-featured Flutter application while adhering to industry best practices. From efficient state management to a seamless user experience, this project showcases my expertise in building high-quality, performant, and scalable mobile apps that are maintainable long-term.

If you’re looking for a **Flutter developer** who thrives under tight deadlines without compromising quality, let’s connect! Feel free to **reach out**, **open an issue**, or **submit a pull request**—I’m always open to new opportunities and collaborations! 🚀

### 🔗 Checkout my other work

[CannaBook](https://cannabook.tech) - A personal project with over **20,000 downloads**, **1,000 active users**, and **200 premium subscribers**! This cross-platform (Android & iOS) app fully showcases my ability to build, scale, and monetize Flutter applications.

[Other Projects](https://www.linkedin.com/in/michaelmarsh993/details/projects/) - Explore my portfolio, where I highlight projects that demonstrate my expertise in Flutter, mobile architecture, and scalable app development.
