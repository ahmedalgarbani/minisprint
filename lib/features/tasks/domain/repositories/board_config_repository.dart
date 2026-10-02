import '../../../../core/utils/result.dart';
import '../entities/board_config.dart';

abstract class BoardConfigRepository {
  Future<ApiResult<BoardConfig>> getConfig(int projectId);
  Future<ApiResult<void>> saveConfig(int projectId, BoardConfig config);
}
