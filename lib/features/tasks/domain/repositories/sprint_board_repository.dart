import '../../../../core/utils/result.dart';
import '../entities/sprint_board_config.dart';

abstract class SprintBoardRepository {
  Future<ApiResult<SprintBoardConfig>> getConfig({
    required String userId,
    required int sprintId,
  });

  Future<ApiResult<void>> saveConfig({
    required String userId,
    required int sprintId,
    required SprintBoardConfig config,
  });
}
