/// A utility to launch a URL via the system's native URL launcher.
abstract class UrlLauncher {
  const UrlLauncher._();

  Future<bool> launch(String url);

  Future<bool> canLaunch(String url);
}
