import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/board_config.dart';
import '../models/board_config_model.dart';

/// Board settings are a per-device view preference, so they stay in local
/// storage even when work items come from the remote API.
class BoardConfigLocalDataSource {
  static const _prefix = 'board_config.project';

  Future<BoardConfig> getConfig(int projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('$_prefix.$projectId');
    return value == null
        ? const BoardConfig()
        : BoardConfigModel.fromJson(value);
  }

  Future<void> saveConfig(int projectId, BoardConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix.$projectId',
      BoardConfigModel.toJson(config),
    );
  }
}
