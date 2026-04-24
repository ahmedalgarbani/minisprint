import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_datasource.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectLocalDataSource localDataSource;

  ProjectRepositoryImpl({required this.localDataSource});

  @override
  Future<ApiResult<List<Project>>> getAllProjects() async {
    try {
      final models = await localDataSource.getAllProjects();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Failed to get projects: $e'));
    }
  }

  @override
  Future<ApiResult<Project>> getProjectById(int id) async {
    try {
      final model = await localDataSource.getProjectById(id);
      return Success(model.toEntity());
    } catch (e) {
      return Error(DatabaseFailure('Failed to get project: $e'));
    }
  }

  @override
  Future<ApiResult<Project>> createProject(Project project) async {
    try {
      final model = ProjectModel.fromEntity(project);
      final result = await localDataSource.createProject(model);
      return Success(result.toEntity());
    } catch (e) {
      return Error(DatabaseFailure('Failed to create project: $e'));
    }
  }

  @override
  Future<ApiResult<Project>> updateProject(Project project) async {
    try {
      final model = ProjectModel.fromEntity(project);
      final result = await localDataSource.updateProject(model);
      return Success(result.toEntity());
    } catch (e) {
      return Error(DatabaseFailure('Failed to update project: $e'));
    }
  }

  @override
  Future<ApiResult<void>> deleteProject(int id) async {
    try {
      await localDataSource.deleteProject(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete project: $e'));
    }
  }
}
