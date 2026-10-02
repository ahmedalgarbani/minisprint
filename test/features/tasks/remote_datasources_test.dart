import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/network/api_client.dart';
import 'package:minisprint/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:minisprint/features/sprints/data/datasources/sprint_remote_datasource.dart';
import 'package:minisprint/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:minisprint/features/tasks/domain/entities/task.dart';

import '../../helpers/fakes.dart';

class _RecordingClient implements ApiClient {
  final List<(String, String, Object?)> calls = [];
  final Object? Function(String method, String path) respond;

  _RecordingClient(this.respond);

  @override
  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    calls.add(('GET', path, null));
    return respond('GET', path);
  }

  @override
  Future<dynamic> post(String path, {Object? body}) async {
    calls.add(('POST', path, body));
    return respond('POST', path);
  }

  @override
  Future<dynamic> put(String path, {Object? body}) async {
    calls.add(('PUT', path, body));
    return respond('PUT', path);
  }

  @override
  Future<void> delete(String path) async => calls.add(('DELETE', path, null));
}

void main() {
  test('projects: lists from a {"data": [...]} envelope', () async {
    final client = _RecordingClient(
      (_, _) => {
        'data': [
          {'id': 1, 'name': 'App', 'key': 'APP', 'task_count': 3},
        ],
      },
    );
    final result = await ProjectRemoteDataSource(
      client: client,
    ).getAllProjects();
    expect(client.calls.single.$2, '/projects');
    expect(result.single.displayKey, 'APP');
    expect(result.single.taskCount, 3);
  });

  test('sprints: loads by project and posts new sprints', () async {
    final client = _RecordingClient(
      (method, _) => method == 'GET'
          ? [
              {
                'id': 5,
                'project_id': 1,
                'name': 'S1',
                'start_date': '2026-01-01',
                'end_date': '2026-01-15',
                'status': 'Active',
              },
            ]
          : {
              'id': 6,
              'project_id': 1,
              'name': 'S2',
              'start_date': '2026-01-15',
              'end_date': '2026-01-29',
              'status': 'Planned',
            },
    );
    final source = SprintRemoteDataSource(client: client);

    final loaded = await source.getSprintsByProject(1);
    final created = await source.createSprint(sprint(id: 0).copyWith(id: null));

    expect(loaded.single.isActive, isTrue);
    expect(created.id, 6);
    expect(client.calls.map((c) => '${c.$1} ${c.$2}'), [
      'GET /projects/1/sprints',
      'POST /sprints',
    ]);
  });

  test(
    'tasks: sends tags as a JSON list and keeps the task on empty PUT body',
    () async {
      final client = _RecordingClient((_, _) => null);
      final source = TaskRemoteDataSource(client: client);
      final t = task(id: 9, tags: ['api'], type: WorkItemType.story);

      final updated = await source.updateTask(t);

      final body = client.calls.single.$3! as Map<String, dynamic>;
      expect(client.calls.single.$2, '/tasks/9');
      expect(body['tags'], ['api']);
      expect(body['type'], 'story');
      expect(updated, t);
    },
  );
}
