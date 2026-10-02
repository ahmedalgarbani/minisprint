/// Exceptions thrown by data sources. Repositories catch them and map them to
/// [Failure]s, so they never leave the data layer.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class LocalStorageException extends AppException {
  const LocalStorageException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  final int statusCode;
  const ServerException(this.statusCode, super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}
