import 'package:dio/dio.dart';

class ProofImageUploadDataSource {
  final Dio _dio;

  ProofImageUploadDataSource({required this._dio});

  Future<void> upload({required String uploadUrl, required List<int> fileBytes}) async {
    await _dio.put(
      uploadUrl,
      data: Stream.fromIterable([fileBytes]),
      options: Options(
        headers: {
          Headers.contentLengthHeader: fileBytes.length,
        },
      ),
    );
  }
}