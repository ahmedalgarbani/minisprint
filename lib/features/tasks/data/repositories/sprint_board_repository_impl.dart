import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sprint_board_config.dart';
import '../../domain/repositories/sprint_board_repository.dart';
import '../datasources/sprint_board_local_datasource.dart';

class SprintBoardRepositoryImpl implements SprintBoardRepository {
  final SprintBoardLocalDataSource localDataSource;

  SprintBoardRepositoryImpl({required this.localDataSource});

  @override
  Future<ApiResult<SprintBoardConfig>> getConfig({
    required String userId,
    required int sprintId,
  }) async {
    try {
      return Success(
        await localDataSource.getConfig(userId: userId, sprintId: sprintId),
      );
    } catch (e) {
      return Error(CacheFailure('Failed to load board settings: $e'));
    }
  }

  @override
  Future<ApiResult<void>> saveConfig({
    required String userId,
    required int sprintId,
    required SprintBoardConfig config,
  }) async {
    try {
      await localDataSource.saveConfig(
        userId: userId,
        sprintId: sprintId,
        config: config,
      );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Failed to save board settings: $e'));
    }
  }
}
