import 'package:url_launcher/url_launcher.dart';

class PresentationUtils {
  static Future<bool> openUrl(String url) => launchUrl(Uri.parse(url));

  static String formatSeconds(int? seconds) {
    if (seconds == null) {
      return '';
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
