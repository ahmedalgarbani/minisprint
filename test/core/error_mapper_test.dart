import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/error/error_mapper.dart';
import 'package:minisprint/core/error/exceptions.dart';
import 'package:minisprint/core/error/failure.dart';
import 'package:minisprint/core/utils/result.dart';

void main() {
  test('guard wraps a successful value', () async {
    final result = await guard(() async => 42);
    expect(result.dataOrNull, 42);
  });

  test('maps each AppException to its typed Failure', () {
    expect(
      mapExceptionToFailure(const NotFoundException('x')),
      isA<NotFoundFailure>(),
    );
    expect(
      mapExceptionToFailure(const NetworkException('x')),
      isA<NetworkFailure>(),
    );
    expect(
      mapExceptionToFailure(const UnauthorizedException('x')),
      isA<UnauthorizedFailure>(),
    );
    expect(
      mapExceptionToFailure(const LocalStorageException('x')),
      isA<DatabaseFailure>(),
    );
    final server = mapExceptionToFailure(const ServerException(503, 'down'));
    expect((server as ServerFailure).statusCode, 503);
  });

  test(
    'maps unknown errors to an UnexpectedFailure instead of throwing',
    () async {
      final result = await guard<int>(() async => throw StateError('boom'));
      expect(result.failureOrNull, isA<UnexpectedFailure>());
    },
  );
}
