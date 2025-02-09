import 'package:flutter/material.dart';

import 'package:simply_news/widgets/widgets.dart';

class LoadingLayout extends StatelessWidget {
  /// Creates a new [LoadingLayout].
  const LoadingLayout({
    super.key,
    required this.message,
  });

  /// The message to display while loading.
  ///
  /// Typically this is a [Text] widget.
  final Widget message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: message),
        const SizedBox(height: 24),
        const LoadingIndicator(),
      ],
    );
  }
}
