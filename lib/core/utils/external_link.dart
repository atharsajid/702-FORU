import 'package:url_launcher/url_launcher.dart';

/// Hands a URI off to whatever app the platform has registered for it – the
/// dialer for `tel:`, the browser for `https:`, the mail client for `mailto:`.
///
/// Kept separate from `MapLauncher` so screens can open contact links without
/// importing map-specific code.
class ExternalLink {
  const ExternalLink._();

  /// Returns false when the platform refuses to launch [uri], so the caller can
  /// show a fallback instead of failing silently.
  static Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
