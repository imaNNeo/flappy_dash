import 'package:url_launcher/url_launcher.dart';

class PresentationUtils {
  static Future<bool> openUrl(String url) => launchUrl(Uri.parse(url));
}
