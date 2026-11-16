import 'package:flutter/foundation.dart';

/// Public media base used outside the browser.
///
/// Override at build time if the app is deployed somewhere else:
/// `flutter build apk --dart-define=MEDIA_BASE_URL=https://example.com/media`
const _mediaBaseOverride = String.fromEnvironment('MEDIA_BASE_URL');
const _defaultMediaBase = 'https://panjang-umur.bastenandika.com/media';

/// Resolves a public media URL for display.
///
/// R2's shared `r2.dev` host is blocked by some ISPs (notably in Indonesia) and
/// is on several security blocklists. Web and native builds therefore load
/// those objects through the app's own Vercel deployment, which rewrites
/// `/media/*` to the bucket. The same URL works on every platform.
///
/// Local web development keeps the direct URL because there is no `/media`
/// route on the Flutter dev server.
String resolveImageUrl(String url) {
  if (kIsWeb && _isLocalDevHost(Uri.base.host)) return url;
  return _resolveImageUrl(url, mediaBase: _mediaBase());
}

@visibleForTesting
String resolveImageUrlForTest(String url, {required String mediaBase}) {
  return _resolveImageUrl(url, mediaBase: mediaBase);
}

String _mediaBase() {
  if (kIsWeb) return '${Uri.base.origin}/media';
  return _mediaBaseOverride.isEmpty ? _defaultMediaBase : _mediaBaseOverride;
}

bool _isLocalDevHost(String host) {
  return host == 'localhost' || host == '127.0.0.1' || host == '::1';
}

String _resolveImageUrl(String url, {required String mediaBase}) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty || !uri.host.endsWith('.r2.dev')) {
    return url;
  }

  final base = Uri.parse(mediaBase);
  final basePath = base.path.endsWith('/')
      ? base.path.substring(0, base.path.length - 1)
      : base.path;
  final path = uri.path.startsWith('/') ? uri.path : '/${uri.path}';

  return base
      .replace(
        path: '$basePath$path',
        query: uri.hasQuery ? uri.query : null,
        fragment: null,
      )
      .toString();
}
