import 'package:domain/domain.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherPlugin implements UrlLauncher {
  const UrlLauncherPlugin();

  @override
  Future<bool> launch(String urlString) {
    return launchUrl(Uri.parse(urlString));
  }

  @override
  Future<bool> canLaunch(String urlString) {
    return canLaunchUrl(Uri.parse(urlString));
  }
}
