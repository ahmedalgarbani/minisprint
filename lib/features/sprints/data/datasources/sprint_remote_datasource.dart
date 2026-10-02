import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_utils.dart';
import '../../domain/entities/sprint.dart';
import '../models/sprint_model.dart';
import 'sprint_datasource.dart';

class SprintRemoteDataSource implements SprintDataSource {
  final ApiClient client;

  SprintRemoteDataSource({required this.client});

  @override
  Future<List<Sprint>> getSprintsByProject(int projectId) async {
    final body = await client.get('/projects/$projectId/sprints');
    return jsonList(body).map(SprintModel.fromMap).toList();
  }

  @override
  Future<Sprint> getSprintById(int id) async {
    final body = await client.get('/sprints/$id');
    return SprintModel.fromMap(jsonObject(body));
  }

  @override
  Future<Sprint> createSprint(Sprint sprint) async {
    final body = await client.post('/sprints', body: SprintModel.toMap(sprint));
    return SprintModel.fromMap(jsonObject(body));
  }

  @override
  Future<Sprint> updateSprint(Sprint sprint) async {
    final body = await client.put(
      '/sprints/${sprint.id}',
      body: SprintModel.toMap(sprint),
    );
    return body == null ? sprint : SprintModel.fromMap(jsonObject(body));
  }

  @override
  Future<void> deleteSprint(int id) => client.delete('/sprints/$id');
}
