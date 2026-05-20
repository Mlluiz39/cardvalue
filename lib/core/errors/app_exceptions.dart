class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() => '[$code] $message';
}

class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code, super.stackTrace});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.stackTrace});
}

class AuthException extends AppException {
  AuthException(super.message, {super.code, super.stackTrace});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.stackTrace});
}
