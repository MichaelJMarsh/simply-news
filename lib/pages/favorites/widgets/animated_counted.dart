import 'package:flutter/widgets.dart';

/// A widget that animates a counter from 0 to a given value.
class AnimatedCounter extends StatelessWidget {
  /// Creates a new [AnimatedCounter].
  const AnimatedCounter(
    this.value, {
    super.key,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 450),
    this.style,
  }) : assert(value >= 0, 'The count must be greater than or equal to 0.');

  /// The current value to animate to.
  final int value;

  /// The style of the text displayed.
  final TextStyle? style;

  /// The curve of the counting animation.
  final Curve curve;

  /// The duration of the counting animation.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<num>(
      tween: Tween<num>(begin: 0.0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (_, animationValue, __) {
        return Text(
          animationValue.toString(),
          style: style,
        );
      },
    );
  }
}
