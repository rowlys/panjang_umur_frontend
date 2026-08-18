import 'package:panjang_umur_frontend/core/network/dio_client.dart';
import 'package:panjang_umur_frontend/features/auth/domain/models/auth.dart';

class AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSource(this._client);

  Future<AuthSession> logIn(String username, String password) async {
    final response = await _client.post('/auth/login', data: {
      'username': username,
      'password': password,
    });

    return AuthSession.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> register(String name, String username, String password) async {
    final response = await _client.post('/auth/register', data: {
      'name': name,
      'username': username,
      'password': password,
    });

    return response.data['userId'] as String;
  }

  Future<User> getMe() async {
    final response = await _client.get('/auth/me');
    
    final user = User.fromJson(response.data as Map<String, dynamic>);

    return user;
  }
}