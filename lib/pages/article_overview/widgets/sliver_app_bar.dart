import 'package:flutter/material.dart';

/// A custom designed app bar that is typically used as the first element
/// in a [CustomScrollView].
///
/// This displays a leading widget, a title widget, and a trailing widget.
class SliverAppBar extends StatelessWidget {
  /// Creates a new [SliverAppBar].
  const SliverAppBar({
    super.key,
    this.height = 40,
    this.primary = true,
    this.leading,
    this.title,
    this.subtitle,
    this.actions = const [],
  });

  /// The height of the app bar.
  final double height;

  /// Whether this app bar is being displayed at the top of the screen.
  ///
  /// If true, the [SliverAppBar] will be padded on top by the height of the
  /// system status bar.
  final bool primary;

  /// The widget to display at the start of the app bar.
  ///
  /// Typically, an [IconButton] widget.
  final Widget? leading;

  /// The widget to display in the center of the app bar.
  ///
  /// Typically, a [Text] widget.
  final Widget? title;

  /// The widget to display below the [title].
  ///
  /// Typically, a [Text] widget.
  final Widget? subtitle;

  /// The widgets to display in a [Row] at the end of the app bar.
  ///
  /// Typically, [IconButton] widgets.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        height: height,
        topPadding: !primary ? 0 : 24 + MediaQuery.paddingOf(context).top,
        leading: leading,
        title: title,
        subtitle: subtitle,
        actions: actions,
      ),
    );
  }
}

/// A delegate that supplies a [SliverPersistentHeader] widget with a custom
/// layout.
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  /// Creates a new [_SliverAppBarDelegate].
  const _SliverAppBarDelegate({
    required this.height,
    required this.topPadding,
    this.leading,
    this.title,
    this.subtitle,
    this.actions = const [],
  });

  /// The height of the app bar.
  ///
  /// Defaults to 72.
  final double height;

  /// The padding above the app bar.
  final double topPadding;

  /// The widget to display at the start of the app bar.
  ///
  /// Typically, an [IconButton] widget.
  final Widget? leading;

  /// The widget to display in the center of the app bar.
  ///
  /// Typically, a [Text] widget.
  final Widget? title;

  /// The widget to display below the [title].
  ///
  /// Typically, a [Text] widget.
  final Widget? subtitle;

  /// The widgets to display in a [Row] at the end of the app bar.
  ///
  /// Typically, [IconButton] widgets.
  final List<Widget> actions;

  @override
  double get maxExtent => height + topPadding;

  @override
  double get minExtent => maxExtent;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return height != oldDelegate.height ||
        topPadding != oldDelegate.topPadding ||
        leading != oldDelegate.leading ||
        title != oldDelegate.title ||
        subtitle != oldDelegate.subtitle ||
        actions != oldDelegate.actions;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    const horizontalPadding = 24.0;

    final displayTitleOnly =
        title != null && subtitle == null && leading == null && actions.isEmpty;

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding,
        left: horizontalPadding,
        right: horizontalPadding,
      ),
      child: IconTheme(
        data: IconThemeData(
          color: colorScheme.onSurface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!displayTitleOnly) ...[
              leading ?? const SizedBox(width: 40),
              const SizedBox(width: 8),
            ],
            if (title != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DefaultTextStyle.merge(
                      child: title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 20 / 16,
                        letterSpacing: 0.4,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (title != null && subtitle != null) ...[
                      const SizedBox(height: 4),
                      DefaultTextStyle.merge(
                        child: subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 16 / 12,
                          letterSpacing: 0.3,
                          color: colorScheme.onSurface.withOpacity(0.48),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (!displayTitleOnly) ...[
              const SizedBox(width: 8),
              if (actions.isEmpty)
                const SizedBox(width: 40)
              else
                ...Iterable.generate(
                  actions.length,
                  (index) {
                    final action = actions[index];

                    return index == 0
                        ? action
                        : Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: action,
                          );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}
