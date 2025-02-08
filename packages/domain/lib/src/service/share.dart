import 'dart:ui';

/// A utility to launch a URL via the system's native URL launcher.
abstract class Share {
  const Share._();

  Future<bool> send({
    final String? subject,
    final String? message,
    required String content,
    required Rect? sharePositionOrigin,
  });
}
