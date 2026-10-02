import '../../../../core/error/error_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sprint.dart';
import '../../domain/repositories/sprint_repository.dart';
import '../datasources/sprint_datasource.dart';

class SprintRepositoryImpl implements SprintRepository {
  final SprintDataSource dataSource;

  SprintRepositoryImpl({required this.dataSource});

  @override
  Future<ApiResult<List<Sprint>>> getSprintsByProject(int projectId) =>
      guard(() => dataSource.getSprintsByProject(projectId));

  @override
  Future<ApiResult<Sprint>> getSprintById(int id) =>
      guard(() => dataSource.getSprintById(id));

  @override
  Future<ApiResult<Sprint>> createSprint(Sprint sprint) =>
      guard(() => dataSource.createSprint(sprint));

  @override
  Future<ApiResult<Sprint>> updateSprint(Sprint sprint) =>
      guard(() => dataSource.updateSprint(sprint));

  @override
  Future<ApiResult<void>> deleteSprint(int id) =>
      guard(() => dataSource.deleteSprint(id));
}
