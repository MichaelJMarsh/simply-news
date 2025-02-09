import 'dart:ui';

import 'package:domain/domain.dart';
import 'package:share_plus/share_plus.dart' as package;

class SharePlugin implements Share {
  /// Creates a new [SharePlugin].
  const SharePlugin({
    required ShareDelegate delegate,
  }) : _delegate = delegate;

  final ShareDelegate _delegate;

  /// Summons the platform's share sheet to send text.
  ///
  /// Wraps the platform's native share dialog. Can send a text and/or a URL.
  /// It uses the `ACTION_SEND` Intent on Android and `UIActivityViewController`
  /// on iOS.
  ///
  /// The optional [subject] parameter can be used to populate a subject if the
  /// user chooses to send an email.
  ///
  /// The optional [message] parameter can be used to populate text in the body of the
  /// shared [content]. This is displayed one line above the [content].
  @override
  Future<bool> send({
    final String? subject,
    final String? message,
    required Rect? sharePositionOrigin,
    required String content,
  }) async {
    var defaultContentFormat = content;

    if (message != null) {
      defaultContentFormat = '$message\n\n$content';
    }

    final result = await _delegate.share(
      defaultContentFormat,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );

    if (result.status != package.ShareResultStatus.unavailable) {
      return true;
    }

    return false;
  }
}

/// A delegate for the platform's share sheet.
class ShareDelegate {
  /// Summons the platform's share sheet to send text.
  Future<package.ShareResult> share(
    String text, {
    String? subject,
    Rect? sharePositionOrigin,
  }) {
    return package.Share.share(
      text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
