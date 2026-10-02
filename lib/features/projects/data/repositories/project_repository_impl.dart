import '../../../../core/error/error_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_datasource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectDataSource dataSource;

  ProjectRepositoryImpl({required this.dataSource});

  @override
  Future<ApiResult<List<Project>>> getAllProjects() =>
      guard(dataSource.getAllProjects);

  @override
  Future<ApiResult<Project>> getProjectById(int id) =>
      guard(() => dataSource.getProjectById(id));

  @override
  Future<ApiResult<Project>> createProject(Project project) =>
      guard(() => dataSource.createProject(project));

  @override
  Future<ApiResult<Project>> updateProject(Project project) =>
      guard(() => dataSource.updateProject(project));

  @override
  Future<ApiResult<void>> deleteProject(int id) =>
      guard(() => dataSource.deleteProject(id));
}
