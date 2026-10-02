import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/features/tasks/data/models/task_model.dart';
import 'package:minisprint/features/tasks/domain/entities/task.dart';

import '../../helpers/fakes.dart';

void main() {
  test('stores tags as CSV in SQLite and as a list in JSON', () {
    final t = task(id: 1, tags: ['api', 'ui']);
    expect(TaskModel.toMap(t)['tags'], 'api,ui');
    expect(TaskModel.toJson(t)['tags'], ['api', 'ui']);
  });

  test('reads both tag formats back', () {
    final fromDb = TaskModel.fromMap({
      'id': 1,
      'project_id': 1,
      'title': 'A',
      'tags': 'api, ui',
    });
    final fromApi = TaskModel.fromMap({
      'id': 1,
      'project_id': 1,
      'title': 'A',
      'tags': ['api', 'ui'],
    });
    expect(fromDb.tags, ['api', 'ui']);
    expect(fromApi.tags, ['api', 'ui']);
  });

  test('accepts numeric strings from APIs and defaults missing fields', () {
    final t = TaskModel.fromMap({
      'id': '7',
      'project_id': '2',
      'sprint_id': null,
      'title': 'A',
      'story_points': 5.0,
    });
    expect(t.id, 7);
    expect(t.projectId, 2);
    expect(t.isInBacklog, isTrue);
    expect(t.storyPoints, 5);
    expect(t.type, WorkItemType.task);
    expect(t.status, 'To Do');
  });
}
