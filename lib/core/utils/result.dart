import '../error/failure.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends ApiResult<T> {
  final Failure failure;
  const Error(this.failure);
}

extension ApiResultExtension<T> on ApiResult<T> {
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onFailure(failure),
    };
  }

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Error<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Error<T>(:final failure) => failure,
  };
}
