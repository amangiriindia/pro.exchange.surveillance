class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}

class CacheException extends AppException {
  CacheException(String message) : super(message);
}

class ServerException extends AppException {
  ServerException(String message) : super(message);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}

class NoDataException extends AppException {
  NoDataException(String message) : super(message);
}
