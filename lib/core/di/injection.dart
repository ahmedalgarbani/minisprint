import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';
import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/usecases/project_usecases.dart';
import '../../features/projects/presentation/cubit/project_cubit.dart';
import '../../features/sprints/data/datasources/sprint_local_datasource.dart';
import '../../features/sprints/data/repositories/sprint_repository_impl.dart';
import '../../features/sprints/domain/repositories/sprint_repository.dart';
import '../../features/sprints/domain/usecases/sprint_usecases.dart';
import '../../features/sprints/presentation/cubit/sprint_cubit.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/sprint_board_local_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/data/repositories/sprint_board_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/repositories/sprint_board_repository.dart';
import '../../features/tasks/domain/usecases/task_usecases.dart';
import '../../features/tasks/domain/usecases/sprint_board_usecases.dart';
import '../../features/tasks/presentation/cubit/task_cubit.dart';
import '../../features/tasks/presentation/cubit/sprint_board_cubit.dart';
import '../../features/settings/presentation/cubit/theme_settings_cubit.dart';
import '../theme/theme_settings_datasource.dart';


final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Database
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Settings
  getIt.registerLazySingleton<ThemeSettingsDataSource>(() => ThemeSettingsDataSource());
  getIt.registerLazySingleton<ThemeSettingsCubit>(
    () => ThemeSettingsCubit(dataSource: getIt()),
  );

  // Project
  getIt.registerLazySingleton<ProjectLocalDataSource>(
    () => ProjectLocalDataSourceImpl(databaseHelper: getIt()),
  );
  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetAllProjects(getIt()));
  getIt.registerLazySingleton(() => GetProjectById(getIt()));
  getIt.registerLazySingleton(() => CreateProject(getIt()));
  getIt.registerLazySingleton(() => UpdateProject(getIt()));
  getIt.registerLazySingleton(() => DeleteProject(getIt()));
  getIt.registerFactory(
    () => ProjectCubit(
      getAllProjects: getIt(),
      createProject: getIt(),
      updateProject: getIt(),
      deleteProject: getIt(),
    ),
  );

  // Sprint
  getIt.registerLazySingleton<SprintLocalDataSource>(
    () => SprintLocalDataSourceImpl(databaseHelper: getIt()),
  );
  getIt.registerLazySingleton<SprintRepository>(
    () => SprintRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetAllSprints(getIt()));
  getIt.registerLazySingleton(() => GetSprintsByProject(getIt()));
  getIt.registerLazySingleton(() => GetSprintById(getIt()));
  getIt.registerLazySingleton(() => CreateSprint(getIt()));
  getIt.registerLazySingleton(() => UpdateSprint(getIt()));
  getIt.registerLazySingleton(() => DeleteSprint(getIt()));
  getIt.registerFactory(
    () => SprintCubit(
      getAllSprints: getIt(),
      getSprintsByProject: getIt(),
      createSprint: getIt(),
      updateSprint: getIt(),
      deleteSprint: getIt(),
    ),
  );

  // Task
  getIt.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(databaseHelper: getIt()),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<SprintBoardLocalDataSource>(
    () => SprintBoardLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<SprintBoardRepository>(
    () => SprintBoardRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetTasksBySprint(getIt()));
  getIt.registerLazySingleton(() => GetTaskById(getIt()));
  getIt.registerLazySingleton(() => CreateTask(getIt()));
  getIt.registerLazySingleton(() => UpdateTask(getIt()));
  getIt.registerLazySingleton(() => DeleteTask(getIt()));
  getIt.registerLazySingleton(() => GetSprintBoardConfig(getIt()));
  getIt.registerLazySingleton(() => SaveSprintBoardConfig(getIt()));
  getIt.registerFactory(
    () => TaskCubit(
      getTasksBySprint: getIt(),
      createTask: getIt(),
      updateTask: getIt(),
      deleteTask: getIt(),
    ),
  );
  getIt.registerFactory(
    () => SprintBoardCubit(
      getConfig: getIt(),
      saveConfig: getIt(),
    ),
  );
}
