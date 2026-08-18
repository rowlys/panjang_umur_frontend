import 'package:panjang_umur_frontend/core/network/dio_client.dart';

class AuthLocalDataSource {
  final DioClient _client;

  AuthLocalDataSource(this._client);

  Future<void> setToken(String token) async {
    try {
      await _client.saveToken(token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  Future<void> logOut() async {
    try {
      await _client.clearToken();
    } catch (e) {
      throw Exception('Failed to clear token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _client.getToken();
    } catch (e) {
      throw Exception('Failed to get token: $e');
    }
  }
}