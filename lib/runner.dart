import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'bootstrap.dart';

/// The widget which attempts to run the [CannaBookApp].
///
/// If the [CannaBookApp] is still initializing, a splash screen is displayed.
///
/// If the [CannaBookApp] fails to initialize, an error screen is displayed.
///
/// The [CannaBookApp] is displayed once it has been successfully initialized.
class Runner extends StatefulWidget {
  /// Creates a new [Runner].
  const Runner({super.key});

  @override
  State<StatefulWidget> createState() => _RunnerState();
}

class _RunnerState extends State<Runner> {
  SimplyNewsApp? _app;
  Object? _error;

  @override
  void initState() {
    super.initState();

    _initializeApp();
  }

  /// Attempts to initialize the [CannaBookApp], then updates the state.
  Future<void> _initializeApp() async {
    try {
      final app = await bootstrap();

      if (!mounted) return;

      setState(() => _app = app);
    } catch (exception, _) {
      if (!mounted) return;

      setState(() => _error = exception);

      if (!kDebugMode) {
        // Record the error to Firebase Crashlytics or similar service.
      }
    }
  }

  /// Resets the app and error states to null.
  void _resetInitializationState() {
    setState(() {
      _app = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayApp = _app != null;
    final displayError = _error != null;

    Widget child = const _SplashScreen();

    if (displayError) {
      child = _ErrorScreen(
        key: Key('error_screen.$displayError'),
        onRetry: () {
          _resetInitializationState();
          _initializeApp();
        },
      );
    } else if (displayApp) {
      child = KeyedSubtree(
        key: Key('app.$displayApp'),
        child: _app!,
      );
    }

    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.fastOutSlowIn,
        child: child,
      ),
    );
  }
}

/// A basic splash screen implementation, used to display a [LoadingIndicatorPulse].
class _SplashScreen extends StatelessWidget {
  /// Creates a new [_SplashScreen].
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _Scaffold(
      backgroundColor: colorScheme.surface,
      body: const Text('Loading Simply News ...'),
    );
  }
}

/// A basic error screen implementation, used to display an error message.
class _ErrorScreen extends StatelessWidget {
  /// Creates a new [_ErrorScreen].
  const _ErrorScreen({super.key, required this.onRetry});

  /// The function called when the user taps the retry button.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQueryPadding = MediaQuery.of(context).padding;

    const buttonHeight = 56.0;

    return _Scaffold(
      backgroundColor: colorScheme.error,
      body: Column(
        children: [
          SizedBox(height: buttonHeight + mediaQueryPadding.top),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 295),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'It looks like something went wrong.',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 24 / 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'PLEASE USE THE BUTTON BELOW TO TRY '
                    'LOADING SIMPLY NEWS AGAIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 20 / 14,
                      color: colorScheme.onPrimary.withOpacity(0.64),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: ElevatedButton(
              onPressed: onRetry,
              child: const Text('RETRY'),
            ),
          ),
          SizedBox(height: 24 + mediaQueryPadding.bottom),
        ],
      ),
    );
  }
}

/// A basic scaffold implementation, used to display a splash screen.
class _Scaffold extends StatelessWidget {
  /// Creates a new [_Scaffold].
  const _Scaffold({
    required this.backgroundColor,
    required this.body,
  });

  /// The background color of the scaffold.
  final Color backgroundColor;

  /// The primary content of the scaffold.
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: Center(
          child: body,
        ),
      ),
    );
  }
}
