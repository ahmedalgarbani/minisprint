import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/sprint_board_config.dart';
import '../models/sprint_board_config_model.dart';

abstract class SprintBoardLocalDataSource {
  Future<SprintBoardConfig> getConfig({
    required String userId,
    required int sprintId,
  });
  Future<void> saveConfig({
    required String userId,
    required int sprintId,
    required SprintBoardConfig config,
  });
}

class SprintBoardLocalDataSourceImpl implements SprintBoardLocalDataSource {
  static const _defaultUserId = 'local_user';
  static const _modePrefix = 'sprint_board_mode';
  static const _configPrefix = 'sprint_board_config';

  @override
  Future<SprintBoardConfig> getConfig({
    required String userId,
    required int sprintId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId.isEmpty ? _defaultUserId : userId;
    final modeName = prefs.getString(_modeKey(effectiveUserId));
    final mode = BoardMode.values.byName(modeName ?? BoardMode.simple.name);
    final value = prefs.getString(_configKey(effectiveUserId, sprintId));
    if (value == null) {
      return SprintBoardConfig.defaults(mode: mode);
    }

    final config = SprintBoardConfigModel.fromJson(value);
    if (config.mode == mode) return config;
    return config.copyWith(mode: mode);
  }

  @override
  Future<void> saveConfig({
    required String userId,
    required int sprintId,
    required SprintBoardConfig config,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId.isEmpty ? _defaultUserId : userId;
    await prefs.setString(_modeKey(effectiveUserId), config.mode.name);
    await prefs.setString(
      _configKey(effectiveUserId, sprintId),
      SprintBoardConfigModel.toJson(config),
    );
  }

  String _modeKey(String userId) => '$_modePrefix.$userId';

  String _configKey(String userId, int sprintId) {
    return '$_configPrefix.$userId.$sprintId';
  }
}
