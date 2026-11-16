import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:panjang_umur_frontend/core/error/exceptions.dart';

/// Uploads image bytes to a presigned URL. This deliberately uses a plain Dio
/// instance: the presigned URL is the credential and an app Authorization
/// header is not part of the signature.
class AvatarUploadDataSource {
  final Dio _dio;

  AvatarUploadDataSource(this._dio);

  Future<void> upload({required String uploadUrl, required Uint8List bytes}) async {
    try {
      await _dio.put(
        uploadUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            Headers.contentLengthHeader: bytes.length,
          },
        ),
      );
    } on DioException {
      throw NetworkException('Failed to upload the photo');
    }
  }
}
