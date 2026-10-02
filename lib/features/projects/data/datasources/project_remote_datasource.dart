import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_utils.dart';
import '../../domain/entities/project.dart';
import '../models/project_model.dart';
import 'project_datasource.dart';

class ProjectRemoteDataSource implements ProjectDataSource {
  final ApiClient client;

  ProjectRemoteDataSource({required this.client});

  @override
  Future<List<Project>> getAllProjects() async {
    final body = await client.get('/projects');
    return jsonList(body).map(ProjectModel.fromMap).toList();
  }

  @override
  Future<Project> getProjectById(int id) async {
    final body = await client.get('/projects/$id');
    return ProjectModel.fromMap(jsonObject(body));
  }

  @override
  Future<Project> createProject(Project project) async {
    final body = await client.post(
      '/projects',
      body: ProjectModel.toMap(project),
    );
    return ProjectModel.fromMap(jsonObject(body));
  }

  @override
  Future<Project> updateProject(Project project) async {
    final body = await client.put(
      '/projects/${project.id}',
      body: ProjectModel.toMap(project),
    );
    return body == null ? project : ProjectModel.fromMap(jsonObject(body));
  }

  @override
  Future<void> deleteProject(int id) => client.delete('/projects/$id');
}
