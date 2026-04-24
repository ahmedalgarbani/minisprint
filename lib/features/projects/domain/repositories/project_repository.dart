import '../../../../core/utils/result.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  Future<ApiResult<List<Project>>> getAllProjects();
  Future<ApiResult<Project>> getProjectById(int id);
  Future<ApiResult<Project>> createProject(Project project);
  Future<ApiResult<Project>> updateProject(Project project);
  Future<ApiResult<void>> deleteProject(int id);
}
