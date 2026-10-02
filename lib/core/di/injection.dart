import 'package:get_it/get_it.dart';

import '../../features/projects/data/datasources/project_datasource.dart';
import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/datasources/project_remote_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/usecases/get_project_workspace.dart';
import '../../features/projects/domain/usecases/project_usecases.dart';
import '../../features/projects/presentation/cubit/project_cubit.dart';
import '../../features/projects/presentation/cubit/project_workspace_cubit.dart';
import '../../features/reports/domain/usecases/build_sprint_report.dart';
import '../../features/settings/data/datasources/backup_local_datasource.dart';
import '../../features/settings/data/repositories/backup_repository_impl.dart';
import '../../features/settings/domain/repositories/backup_repository.dart';
import '../../features/settings/domain/usecases/backup_usecases.dart';
import '../../features/settings/presentation/cubit/data_settings_cubit.dart';
import '../../features/settings/presentation/cubit/theme_settings_cubit.dart';
import '../../features/sprints/data/datasources/sprint_datasource.dart';
import '../../features/sprints/data/datasources/sprint_local_datasource.dart';
import '../../features/sprints/data/datasources/sprint_remote_datasource.dart';
import '../../features/sprints/data/repositories/sprint_repository_impl.dart';
import '../../features/sprints/domain/repositories/sprint_repository.dart';
import '../../features/sprints/domain/usecases/sprint_usecases.dart';
import '../../features/tasks/data/datasources/board_config_local_datasource.dart';
import '../../features/tasks/data/datasources/task_datasource.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/task_remote_datasource.dart';
import '../../features/tasks/data/repositories/board_config_repository_impl.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/board_config_repository.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/board_config_usecases.dart';
import '../../features/tasks/domain/usecases/build_board_view.dart';
import '../../features/tasks/domain/usecases/task_usecases.dart';
import '../../features/tasks/presentation/cubit/board_cubit.dart';
import '../config/app_config.dart';
import '../database/database_helper.dart';
import '../network/api_client.dart';
import '../network/http_api_client.dart';
import '../theme/theme_settings_datasource.dart';

final getIt = GetIt.instance;

/// Registers all dependencies.
///
/// The only place that knows whether data comes from SQLite or the REST API:
/// repositories depend on the `*DataSource` interfaces, so switching backends
/// is a configuration change (see [AppConfig]).
Future<void> initDependencies({AppConfig? config}) async {
  final appConfig = config ?? AppConfig.fromEnvironment();
  getIt.registerSingleton<AppConfig>(appConfig);

  _registerDataSources(appConfig);

  // Settings
  getIt.registerLazySingleton(() => ThemeSettingsDataSource());
  getIt.registerLazySingleton(() => ThemeSettingsCubit(dataSource: getIt()));
  getIt.registerLazySingleton<BackupRepository>(
    () => BackupRepositoryImpl(dataSource: getIt()),
  );
  getIt.registerLazySingleton(() => CreateBackup(getIt()));
  getIt.registerLazySingleton(() => RestoreBackup(getIt()));
  getIt.registerFactory(
    () => DataSettingsCubit(
      config: getIt(),
      createBackup: getIt(),
      restoreBackup: getIt(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(dataSource: getIt()),
  );
  getIt.registerLazySingleton<SprintRepository>(
    () => SprintRepositoryImpl(dataSource: getIt()),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(dataSource: getIt()),
  );
  getIt.registerLazySingleton(() => BoardConfigLocalDataSource());
  getIt.registerLazySingleton<BoardConfigRepository>(
    () => BoardConfigRepositoryImpl(localDataSource: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetAllProjects(getIt()));
  getIt.registerLazySingleton(() => CreateProject(getIt()));
  getIt.registerLazySingleton(() => UpdateProject(getIt()));
  getIt.registerLazySingleton(() => DeleteProject(getIt()));
  getIt.registerLazySingleton(
    () => GetProjectWorkspace(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => CreateSprint(getIt()));
  getIt.registerLazySingleton(() => UpdateSprint(getIt()));
  getIt.registerLazySingleton(() => DeleteSprint(getIt()));
  getIt.registerLazySingleton(() => StartSprint(getIt()));
  getIt.registerLazySingleton(() => CompleteSprint(getIt(), getIt()));
  getIt.registerLazySingleton(() => CreateTask(getIt()));
  getIt.registerLazySingleton(() => UpdateTask(getIt()));
  getIt.registerLazySingleton(() => DeleteTask(getIt()));
  getIt.registerLazySingleton(() => MoveTaskToSprint(getIt()));
  getIt.registerLazySingleton(() => ChangeTaskStatus(getIt()));
  getIt.registerLazySingleton(() => GetBoardConfig(getIt()));
  getIt.registerLazySingleton(() => SaveBoardConfig(getIt()));
  getIt.registerLazySingleton(() => const BuildBoardView());
  getIt.registerLazySingleton(() => const BuildSprintReport());

  // Cubits
  getIt.registerFactory(
    () => ProjectCubit(
      getAllProjects: getIt(),
      createProject: getIt(),
      updateProject: getIt(),
      deleteProject: getIt(),
    ),
  );
  getIt.registerFactory(
    () => ProjectWorkspaceCubit(
      getWorkspace: getIt(),
      createTask: getIt(),
      updateTask: getIt(),
      deleteTask: getIt(),
      moveTaskToSprint: getIt(),
      changeTaskStatus: getIt(),
      createSprint: getIt(),
      updateSprint: getIt(),
      deleteSprint: getIt(),
      startSprint: getIt(),
      completeSprint: getIt(),
      buildSprintReport: getIt(),
    ),
  );
  getIt.registerFactory(
    () => BoardCubit(
      getConfig: getIt(),
      saveConfig: getIt(),
      buildBoardView: getIt(),
    ),
  );
}

void _registerDataSources(AppConfig config) {
  // Local database is always registered: backups use it in local mode.
  getIt.registerLazySingleton(() => DatabaseHelper());
  getIt.registerLazySingleton(
    () => BackupLocalDataSource(databaseHelper: getIt()),
  );

  switch (config.dataSource) {
    case DataSourceType.local:
      getIt.registerLazySingleton<ProjectDataSource>(
        () => ProjectLocalDataSource(databaseHelper: getIt()),
      );
      getIt.registerLazySingleton<SprintDataSource>(
        () => SprintLocalDataSource(databaseHelper: getIt()),
      );
      getIt.registerLazySingleton<TaskDataSource>(
        () => TaskLocalDataSource(databaseHelper: getIt()),
      );
    case DataSourceType.remote:
      getIt.registerLazySingleton<ApiClient>(
        () => HttpApiClient(
          baseUrl: config.apiBaseUrl,
          timeout: config.requestTimeout,
          // Plug token storage here once the backend has authentication.
        ),
      );
      getIt.registerLazySingleton<ProjectDataSource>(
        () => ProjectRemoteDataSource(client: getIt()),
      );
      getIt.registerLazySingleton<SprintDataSource>(
        () => SprintRemoteDataSource(client: getIt()),
      );
      getIt.registerLazySingleton<TaskDataSource>(
        () => TaskRemoteDataSource(client: getIt()),
      );
  }
}
