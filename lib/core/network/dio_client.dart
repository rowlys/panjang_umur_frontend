import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/foundation.dart';

import '../error/exceptions.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  final VoidCallback onUnauthorized;

  String? _cachedToken;
  bool _isTokenLoaded = false;

  DioClient(this._storage, this.onUnauthorized) : _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_BASE_URL'] ?? '',
    connectTimeout: const Duration(seconds: 10),
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!_isTokenLoaded) {
          _cachedToken = await _storage.read(key: 'auth_token');
          _isTokenLoaded = true;
        }

        if (_cachedToken != null) {
          options.headers['Authorization'] = 'Bearer $_cachedToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          clearToken();
          onUnauthorized();
        }
        return handler.next(e);
      }
    ));
  }

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: 'auth_token', value: token);
      _cachedToken = token;
      _isTokenLoaded = true;
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: 'auth_token');
      _cachedToken = null;
      _isTokenLoaded = false;
    } catch (e) {
      throw Exception('Failed to clear token: $e');
    }
  }

  Future<String?> getToken() async {
    if (!_isTokenLoaded) {
      try {
        _cachedToken = await _storage.read(key: 'auth_token');
        if (_cachedToken != null) {
          _isTokenLoaded = true;
        }
      } catch (e) {
        throw Exception('Failed to get token: $e');
      }
    }
    return _cachedToken;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid credentials: ${e.message}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
        throw UnexpectedException('Unexpected error: ${e.toString()}');
    }
  }

  Future<Response> post(String path, {Object? data}) async {
    try {
      return _dio.post(path, data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid credentials: ${e.message}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        throw ServerException('Server error: ${e.message}');
      } 
    } catch (e) {
        throw UnexpectedException('Unexpected error: ${e.toString()}');
    }
  }

  Future<Response> put(String path, {Object? data}) async {
    try {
      return _dio.put(path, data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid credentials: ${e.message}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
        throw UnexpectedException('Unexpected error: ${e.toString()}');
    }

  }

  Future<Response> patch(String path, {Object? data}) async {
    try {
      return _dio.patch(path, data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid credentials: ${e.message}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
        throw UnexpectedException('Unexpected error: ${e.toString()}');
    }
  }

  Future<Response> delete(String path, {Object? data}) async {
    try {
      return _dio.delete(path, data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid credentials: ${e.message}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
        throw UnexpectedException('Unexpected error: ${e.toString()}');
    }
  }

}