import '../../../../core/utils/result.dart';
import '../entities/sprint_board_config.dart';
import '../repositories/sprint_board_repository.dart';

class GetSprintBoardConfig {
  final SprintBoardRepository repository;

  GetSprintBoardConfig(this.repository);

  Future<ApiResult<SprintBoardConfig>> call({
    required String userId,
    required int sprintId,
  }) {
    return repository.getConfig(userId: userId, sprintId: sprintId);
  }
}

class SaveSprintBoardConfig {
  final SprintBoardRepository repository;

  SaveSprintBoardConfig(this.repository);

  Future<ApiResult<void>> call({
    required String userId,
    required int sprintId,
    required SprintBoardConfig config,
  }) {
    return repository.saveConfig(
      userId: userId,
      sprintId: sprintId,
      config: config,
    );
  }
}
