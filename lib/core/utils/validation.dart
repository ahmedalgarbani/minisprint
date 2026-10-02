import '../error/failure.dart';
import 'result.dart';

/// Stable identifiers for validation rules. Presentation maps them to
/// localized messages.
class ValidationCodes {
  static const requiredName = 'required_name';
  static const requiredTitle = 'required_title';
  static const invalidDateRange = 'invalid_date_range';
  static const activeSprintExists = 'active_sprint_exists';
  static const sprintNotActive = 'sprint_not_active';
  static const sprintNotPlanned = 'sprint_not_planned';
  static const invalidStoryPoints = 'invalid_story_points';
}

Error<T> invalid<T>(String code) => Error<T>(ValidationFailure(code));
