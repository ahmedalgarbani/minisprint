import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/backup_usecases.dart';

class DataSettingsState extends Equatable {
  final DataSourceType source;
  final String apiBaseUrl;
  final bool isBusy;

  const DataSettingsState({
    required this.source,
    required this.apiBaseUrl,
    this.isBusy = false,
  });

  bool get supportsBackup => source == DataSourceType.local;

  @override
  List<Object?> get props => [source, apiBaseUrl, isBusy];
}

class DataSettingsCubit extends Cubit<DataSettingsState> {
  final CreateBackup createBackup;
  final RestoreBackup restoreBackup;

  DataSettingsCubit({
    required AppConfig config,
    required this.createBackup,
    required this.restoreBackup,
  }) : super(
         DataSettingsState(
           source: config.dataSource,
           apiBaseUrl: config.apiBaseUrl,
         ),
       );

  /// Returns the saved file path.
  Future<ApiResult<String>> backup() => _busy(createBackup.call);

  /// Returns `false` if the user cancelled.
  Future<ApiResult<bool>> restore() => _busy(restoreBackup.call);

  Future<T> _busy<T>(Future<T> Function() action) async {
    emit(_withBusy(true));
    try {
      return await action();
    } finally {
      if (!isClosed) emit(_withBusy(false));
    }
  }

  DataSettingsState _withBusy(bool busy) => DataSettingsState(
    source: state.source,
    apiBaseUrl: state.apiBaseUrl,
    isBusy: busy,
  );
}
