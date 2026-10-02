import '../../../../core/error/error_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/backup_local_datasource.dart';

class BackupRepositoryImpl implements BackupRepository {
  final BackupLocalDataSource dataSource;

  BackupRepositoryImpl({required this.dataSource});

  @override
  Future<ApiResult<String>> createBackup() =>
      guard(dataSource.createBackupFile);

  @override
  Future<ApiResult<bool>> restoreBackup() => guard(() async {
    final path = await dataSource.pickBackupFile();
    if (path == null) return false;
    await dataSource.importFile(path);
    return true;
  });
}
