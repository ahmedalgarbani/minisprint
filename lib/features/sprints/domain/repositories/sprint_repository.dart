import '../../../../core/utils/result.dart';
import '../entities/sprint.dart';

abstract class SprintRepository {
  Future<ApiResult<List<Sprint>>> getSprintsByProject(int projectId);
  Future<ApiResult<Sprint>> getSprintById(int id);
  Future<ApiResult<Sprint>> createSprint(Sprint sprint);
  Future<ApiResult<Sprint>> updateSprint(Sprint sprint);
  Future<ApiResult<void>> deleteSprint(int id);
}
