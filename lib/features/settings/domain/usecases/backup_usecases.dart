import '../../../../core/utils/result.dart';
import '../repositories/backup_repository.dart';

class CreateBackup {
  final BackupRepository repository;

  CreateBackup(this.repository);

  Future<ApiResult<String>> call() => repository.createBackup();
}

class RestoreBackup {
  final BackupRepository repository;

  RestoreBackup(this.repository);

  Future<ApiResult<bool>> call() => repository.restoreBackup();
}
