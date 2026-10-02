import '../../../../core/utils/result.dart';
import '../entities/board_config.dart';
import '../repositories/board_config_repository.dart';

class GetBoardConfig {
  final BoardConfigRepository repository;

  GetBoardConfig(this.repository);

  Future<ApiResult<BoardConfig>> call(int projectId) {
    return repository.getConfig(projectId);
  }
}

class SaveBoardConfig {
  final BoardConfigRepository repository;

  SaveBoardConfig(this.repository);

  Future<ApiResult<void>> call(int projectId, BoardConfig config) {
    return repository.saveConfig(projectId, config);
  }
}
