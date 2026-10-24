import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hands coordinates off to the device's map app.
///
/// A universal Google Maps link is used on every platform: it opens the native
/// Google Maps app when installed, Apple Maps through the universal-link
/// handoff on iOS, and the web map everywhere else.
class MapLauncher {
  const MapLauncher._();

  /// The exact URI opened for a location. Kept pure so it can be unit tested.
  static Uri uriFor({required double latitude, required double longitude}) {
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$latitude,$longitude',
    });
  }

  /// Opens [uri] in the platform's external map application.
  ///
  /// Returns false when the platform refuses to launch it, so the caller can
  /// fall back to showing the address.
  static Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Convenience wrapper used by the attraction detail page.
  static Future<bool> openCoordinates({
    required double latitude,
    required double longitude,
  }) {
    return open(uriFor(latitude: latitude, longitude: longitude));
  }
}

/// Fallback shown when a device cannot hand off to a map app.
void showMapUnavailable(BuildContext context) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    const SnackBar(
      content: Text('No map app available — the address is shown above.'),
    ),
  );
}
