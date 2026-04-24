import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sprint.dart';
import '../../domain/repositories/sprint_repository.dart';
import '../datasources/sprint_local_datasource.dart';
import '../models/sprint_model.dart';

class SprintRepositoryImpl implements SprintRepository {
  final SprintLocalDataSource localDataSource;

  SprintRepositoryImpl({required this.localDataSource});

  @override
  Future<ApiResult<List<Sprint>>> getAllSprints() async {
    try {
      final models = await localDataSource.getAllSprints();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Failed to get all sprints: $e'));
    }
  }

  @override
  Future<ApiResult<List<Sprint>>> getSprintsByProject(int projectId) async {
    try {
      final models = await localDataSource.getSprintsByProject(projectId);
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Error(DatabaseFailure('Failed to get sprints: $e'));
    }
  }

  @override
  Future<ApiResult<Sprint>> getSprintById(int id) async {
    try {
      final model = await localDataSource.getSprintById(id);
      return Success(model.toEntity());
    } catch (e) {
      return Error(DatabaseFailure('Failed to get sprint: $e'));
    }
  }

  @override
  Future<ApiResult<Sprint>> createSprint(Sprint sprint) async {
    try {
      final model = SprintModel.fromEntity(sprint);
      final result = await localDataSource.createSprint(model);
      return Success(result.toEntity());
    } catch (e) {
      return Error(DatabaseFailure('Failed to create sprint: $e'));
    }
  }

  @override
  Future<ApiResult<Sprint>> updateSprint(Sprint sprint) async {
    try {
      final model = SprintModel.fromEntity(sprint);
      final result = await localDataSource.updateSprint(model);
      return Success(result.toEntity());
    } catch (e) {
      return Error(DatabaseFailure('Failed to update sprint: $e'));
    }
  }

  @override
  Future<ApiResult<void>> deleteSprint(int id) async {
    try {
      await localDataSource.deleteSprint(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure('Failed to delete sprint: $e'));
    }
  }
}
