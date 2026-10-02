import 'package:sqflite/sqflite.dart' show DatabaseException;

import '../utils/result.dart';
import 'exceptions.dart';
import 'failure.dart';

/// Runs a data-source call and converts any exception into a typed [Failure].
///
/// Shared by every repository so local and remote sources fail the same way.
Future<ApiResult<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } catch (error) {
    return Error(mapExceptionToFailure(error));
  }
}

Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    NotFoundException(:final message) => NotFoundFailure(message),
    NetworkException(:final message) => NetworkFailure(message),
    UnauthorizedException(:final message) => UnauthorizedFailure(message),
    ServerException(:final statusCode, :final message) => ServerFailure(
      message,
      statusCode: statusCode,
    ),
    LocalStorageException(:final message) => DatabaseFailure(message),
    DatabaseException() => DatabaseFailure(error.toString()),
    _ => UnexpectedFailure(error.toString()),
  };
}
