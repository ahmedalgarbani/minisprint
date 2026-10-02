import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/error/failure.dart';
import 'package:minisprint/core/utils/result.dart';
import 'package:minisprint/core/utils/validation.dart';
import 'package:minisprint/features/sprints/domain/entities/sprint.dart';
import 'package:minisprint/features/sprints/domain/usecases/sprint_usecases.dart';

import '../../helpers/fakes.dart';

void main() {
  group('CreateSprint', () {
    test('always creates the sprint as planned', () async {
      final repo = FakeSprintRepository();
      final result = await CreateSprint(repo)(
        sprint(id: 0, status: SprintStatus.active).copyWith(name: ' S1 '),
      );
      expect(result.dataOrNull?.status, SprintStatus.planned);
      expect(result.dataOrNull?.name, 'S1');
    });

    test('rejects an end date before the start date', () async {
      final result = await CreateSprint(FakeSprintRepository())(
        sprint(id: 0, start: DateTime(2026, 2, 1), end: DateTime(2026, 1, 1)),
      );
      expect(
        result.failureOrNull,
        const ValidationFailure(ValidationCodes.invalidDateRange),
      );
    });

    test('rejects an empty name', () async {
      final result = await CreateSprint(FakeSprintRepository())(
        sprint(id: 0, name: '  '),
      );
      expect(
        result.failureOrNull,
        const ValidationFailure(ValidationCodes.requiredName),
      );
    });
  });

  group('StartSprint', () {
    test('activates a planned sprint', () async {
      final repo = FakeSprintRepository([sprint(id: 1)]);
      final result = await StartSprint(repo)(repo.sprints[1]!);
      expect(result.dataOrNull?.status, SprintStatus.active);
      expect(repo.sprints[1]!.status, SprintStatus.active);
    });

    test('refuses when another sprint of the project is active', () async {
      final repo = FakeSprintRepository([
        sprint(id: 1),
        sprint(id: 2, status: SprintStatus.active),
      ]);
      final result = await StartSprint(repo)(repo.sprints[1]!);
      expect(
        result.failureOrNull,
        const ValidationFailure(ValidationCodes.activeSprintExists),
      );
      expect(repo.sprints[1]!.status, SprintStatus.planned);
    });

    test('ignores active sprints of other projects', () async {
      final repo = FakeSprintRepository([
        sprint(id: 1),
        sprint(id: 2, projectId: 2, status: SprintStatus.active),
      ]);
      final result = await StartSprint(repo)(repo.sprints[1]!);
      expect(result.isSuccess, isTrue);
    });

    test('refuses to start a completed sprint', () async {
      final repo = FakeSprintRepository([
        sprint(id: 1, status: SprintStatus.completed),
      ]);
      final result = await StartSprint(repo)(repo.sprints[1]!);
      expect(
        result.failureOrNull,
        const ValidationFailure(ValidationCodes.sprintNotPlanned),
      );
    });
  });

  group('CompleteSprint', () {
    test('moves unfinished tasks to the backlog and keeps done ones', () async {
      final sprints = FakeSprintRepository([
        sprint(id: 1, status: SprintStatus.active),
      ]);
      final tasks = FakeTaskRepository([
        task(id: 1, sprintId: 1, status: 'Done'),
        task(id: 2, sprintId: 1, status: 'In Progress'),
        task(id: 3, sprintId: 1, status: 'Review'),
      ]);

      final result = await CompleteSprint(sprints, tasks)(sprints.sprints[1]!);

      expect(result.dataOrNull?.status, SprintStatus.completed);
      expect(tasks.tasks[1]!.sprintId, 1);
      expect(tasks.tasks[2]!.sprintId, isNull);
      expect(tasks.tasks[3]!.sprintId, isNull);
    });

    test('does not complete the sprint when moving a task fails', () async {
      final sprints = FakeSprintRepository([
        sprint(id: 1, status: SprintStatus.active),
      ]);
      final tasks = FakeTaskRepository([task(id: 2, sprintId: 1)])
        ..failUpdatesWith = const NetworkFailure('offline');

      final result = await CompleteSprint(sprints, tasks)(sprints.sprints[1]!);

      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(sprints.sprints[1]!.status, SprintStatus.active);
    });

    test('refuses to complete a sprint that is not active', () async {
      final sprints = FakeSprintRepository([sprint(id: 1)]);
      final result = await CompleteSprint(sprints, FakeTaskRepository())(
        sprints.sprints[1]!,
      );
      expect(
        result.failureOrNull,
        const ValidationFailure(ValidationCodes.sprintNotActive),
      );
    });
  });

  test('SprintStatus reads legacy values and defaults to planned', () {
    expect(SprintStatus.fromValue('Active'), SprintStatus.active);
    expect(SprintStatus.fromValue('completed'), SprintStatus.completed);
    expect(SprintStatus.fromValue(null), SprintStatus.planned);
  });
}
