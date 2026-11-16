import 'package:flutter_test/flutter_test.dart';
import 'package:panjang_umur_frontend/core/utils/image_url.dart';

void main() {
  const mediaBase = 'https://panjang-umur.bastenandika.com/media';
  const bucket = 'https://pub-14fd8aa9e28248008fd0d915cc176c27.r2.dev';

  test('loads r2.dev objects through the media proxy', () {
    expect(
      resolveImageUrlForTest(
        '$bucket/avatars/user/image.jpg',
        mediaBase: mediaBase,
      ),
      '$mediaBase/avatars/user/image.jpg',
    );
  });

  test('keeps other hosts untouched', () {
    const url = 'https://example.com/avatars/user/image.jpg';
    expect(resolveImageUrlForTest(url, mediaBase: mediaBase), url);
  });

  test('does not proxy a lookalike host', () {
    const url =
        'https://pub-14fd8aa9e28248008fd0d915cc176c27.r2.dev.evil.com/a.jpg';
    expect(resolveImageUrlForTest(url, mediaBase: mediaBase), url);
  });

  test('handles a media base with a trailing slash', () {
    expect(
      resolveImageUrlForTest(
        '$bucket/submissions/image-id',
        mediaBase: '$mediaBase/',
      ),
      '$mediaBase/submissions/image-id',
    );
  });

  test('preserves the query string', () {
    expect(
      resolveImageUrlForTest(
        '$bucket/avatars/user/image.jpg?version=2',
        mediaBase: mediaBase,
      ),
      '$mediaBase/avatars/user/image.jpg?version=2',
    );
  });
}
