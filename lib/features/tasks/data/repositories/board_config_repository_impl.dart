import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/board_config.dart';
import '../../domain/repositories/board_config_repository.dart';
import '../datasources/board_config_local_datasource.dart';

class BoardConfigRepositoryImpl implements BoardConfigRepository {
  final BoardConfigLocalDataSource localDataSource;

  BoardConfigRepositoryImpl({required this.localDataSource});

  @override
  Future<ApiResult<BoardConfig>> getConfig(int projectId) async {
    try {
      return Success(await localDataSource.getConfig(projectId));
    } catch (e) {
      // Corrupt preferences must never block the board: fall back to defaults.
      return const Success(BoardConfig());
    }
  }

  @override
  Future<ApiResult<void>> saveConfig(int projectId, BoardConfig config) async {
    try {
      await localDataSource.saveConfig(projectId, config);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Failed to save board settings: $e'));
    }
  }
}
