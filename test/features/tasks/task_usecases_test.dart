import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/error/failure.dart';
import 'package:minisprint/core/utils/result.dart';
import 'package:minisprint/core/utils/validation.dart';
import 'package:minisprint/features/tasks/domain/usecases/task_usecases.dart';

import '../../helpers/fakes.dart';

void main() {
  test('CreateTask trims fields and de-duplicates tags', () async {
    final repo = FakeTaskRepository();
    final result = await CreateTask(repo)(
      task(
        id: 0,
        title: '  Login  ',
        tags: [' api', 'api', '', 'ui '],
      ).copyWith(id: null),
    );
    expect(result.dataOrNull?.title, 'Login');
    expect(result.dataOrNull?.tags, ['api', 'ui']);
  });

  test('CreateTask rejects an empty title', () async {
    final result = await CreateTask(FakeTaskRepository())(
      task(id: 0, title: ' '),
    );
    expect(
      result.failureOrNull,
      const ValidationFailure(ValidationCodes.requiredTitle),
    );
  });

  test('UpdateTask rejects negative story points', () async {
    final result = await UpdateTask(FakeTaskRepository())(
      task(id: 1, points: -1),
    );
    expect(
      result.failureOrNull,
      const ValidationFailure(ValidationCodes.invalidStoryPoints),
    );
  });

  test('MoveTaskToSprint with null moves the task to the backlog', () async {
    final repo = FakeTaskRepository([task(id: 1, sprintId: 5)]);
    await MoveTaskToSprint(repo)(repo.tasks[1]!, null);
    expect(repo.tasks[1]!.sprintId, isNull);
  });

  test('ChangeTaskStatus updates only the status', () async {
    final repo = FakeTaskRepository([task(id: 1, sprintId: 5, title: 'A')]);
    await ChangeTaskStatus(repo)(repo.tasks[1]!, 'Done');
    expect(repo.tasks[1]!.status, 'Done');
    expect(repo.tasks[1]!.title, 'A');
    expect(repo.tasks[1]!.sprintId, 5);
  });
}
