import '../error/failure.dart';
import 'string_helper.dart';
import 'validation.dart';

/// Maps a [Failure] to a user-facing, localized message.
String failureMessage(S s, Failure failure) => switch (failure) {
  ValidationFailure(:final message) => switch (message) {
    ValidationCodes.requiredName => s.errorRequiredName,
    ValidationCodes.requiredTitle => s.errorRequiredTitle,
    ValidationCodes.invalidDateRange => s.errorDateRange,
    ValidationCodes.activeSprintExists => s.errorActiveSprintExists,
    ValidationCodes.sprintNotActive => s.errorSprintNotActive,
    ValidationCodes.sprintNotPlanned => s.errorSprintNotPlanned,
    ValidationCodes.invalidStoryPoints => s.errorStoryPoints,
    _ => s.somethingWentWrong,
  },
  NetworkFailure() => s.errorNetwork,
  UnauthorizedFailure() => s.errorUnauthorized,
  NotFoundFailure() => s.errorNotFound,
  ServerFailure() => s.errorServer,
  DatabaseFailure() || CacheFailure() => s.errorStorage,
  _ => s.somethingWentWrong,
};
