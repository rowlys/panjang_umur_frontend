abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Unauthorized access']) : super(message);
}

class ServerException extends AppException {
  ServerException([String message = 'A server error occurred']) : super(message);
}

class NetworkException extends AppException {
  NetworkException([String message = 'A network connection error occurred']) : super(message);
}

class DataParsingException extends AppException {
  DataParsingException([String message = 'Failed to parse the server response']) : super(message);
}

class CacheException extends AppException {
  CacheException([String message = 'Failed to process local cache']) : super(message);
}

class UnexpectedException extends AppException {
  UnexpectedException([String message = 'An unexpected error occurred']) : super(message);
}