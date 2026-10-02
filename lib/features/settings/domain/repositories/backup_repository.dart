import '../../../../core/utils/result.dart';

abstract class BackupRepository {
  /// Returns the path of the written backup file.
  Future<ApiResult<String>> createBackup();

  /// Returns `false` when the user cancelled the file picker.
  Future<ApiResult<bool>> restoreBackup();
}
