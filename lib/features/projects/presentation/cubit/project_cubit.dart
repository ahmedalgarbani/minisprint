import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/project_usecases.dart';
import 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final GetAllProjects getAllProjects;
  final CreateProject createProject;
  final UpdateProject updateProject;
  final DeleteProject deleteProject;

  ProjectCubit({
    required this.getAllProjects,
    required this.createProject,
    required this.updateProject,
    required this.deleteProject,
  }) : super(const ProjectInitial());

  /// Shows a spinner only on the first load; later reloads keep the list on
  /// screen to avoid flicker.
  Future<void> loadProjects() async {
    if (state is! ProjectsLoaded) emit(const ProjectLoading());
    final result = await getAllProjects();
    if (isClosed) return;
    final query = switch (state) {
      ProjectsLoaded(:final query) => query,
      _ => '',
    };
    result.fold(
      (failure) => emit(ProjectError(failure)),
      (projects) => emit(ProjectsLoaded(projects, query: query)),
    );
  }

  void search(String query) {
    final current = state;
    if (current is ProjectsLoaded) {
      emit(ProjectsLoaded(current.projects, query: query));
    }
  }

  /// Returns `null` on success, otherwise the failure to show.
  Future<Failure?> saveProject(Project project) async {
    final result = project.id == null
        ? await createProject(project)
        : await updateProject(project);
    return _afterMutation(result);
  }

  Future<Failure?> removeProject(int id) async {
    return _afterMutation(await deleteProject(id));
  }

  Future<Failure?> _afterMutation(ApiResult<Object?> result) async {
    final failure = result.failureOrNull;
    if (failure == null) await loadProjects();
    return failure;
  }
}
