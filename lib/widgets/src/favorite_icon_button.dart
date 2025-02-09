import 'package:flutter/material.dart';

/// An animated favorite button that toggles between filled and outlined
/// heart icons when pressed.
class FavoriteIconButton extends StatelessWidget {
  /// Creates a new [FavoriteIconButton].
  const FavoriteIconButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  /// Whether the button is in the favorite state.
  final bool isFavorite;

  /// The function called when the user taps on the [FavoriteIconButton].
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          key: Key(
            'favorite_icon.${isFavorite ? 'favorite' : 'not_favorite'}',
          ),
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : colorScheme.onSurface,
        ),
      ),
    );
  }
}
