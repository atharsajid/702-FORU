/// Remote image URLs, rewritten so the CDN does the shrinking for us.
///
/// Stock-photo CDNs serve the original camera file by default: a single Pexels
/// photo is ~3928x2945 – 408 KB over the wire and, far worse, **44 MB once
/// decoded** into an ARGB bitmap. Painting a grid of those is enough to push a
/// low-end device into an out-of-memory kill after a few minutes of scrolling.
///
/// Rewriting the URL fixes the first half of that problem: the CDN returns a
/// small, already-compressed file at the size we are about to paint, so the
/// download and the disk cache entry both shrink by ~15x. [AppNetworkImage]
/// caps the decoded bitmap as well, for hosts that ignore these parameters.
class ImageUrl {
  const ImageUrl._();

  /// Hosts that honour Imgix-style resize parameters (`w`, `h`, `fit`, ...).
  static const Set<String> _resizableHosts = {'images.pexels.com'};

  /// Hard ceiling on the width of any bitmap we decode, in physical pixels.
  ///
  /// 1080 keeps full-bleed hero images crisp on a 3x phone while capping the
  /// worst-case decoded frame at a few megabytes instead of tens.
  static const int maxDecodePixels = 1080;

  /// Returns [url] pointing at the same photo, but fitting inside
  /// [width] x [height] physical pixels and compressed for the web.
  ///
  /// Unknown hosts (a future backend, for example) are returned untouched so
  /// this stays the single safe entry point for every remote image.
  static String optimized(String url, {int? width, int? height}) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !_resizableHosts.contains(uri.host)) {
      return trimmed;
    }

    // Pexels fits the photo *inside* the requested box and preserves the
    // aspect ratio, so a portrait photo can never come back larger than the
    // box and can never be stretched.
    final query = <String, String>{
      ...uri.queryParameters,
      'auto': 'compress',
      'cs': 'tinysrgb',
      'fit': 'clip',
      'dpr': '1',
      if (width != null && width > 0) 'w': '$width',
      if (height != null && height > 0) 'h': '$height',
    };

    return uri.replace(queryParameters: query).toString();
  }
}
