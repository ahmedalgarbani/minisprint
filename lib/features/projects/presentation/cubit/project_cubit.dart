import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> loadProjects() async {
    emit(const ProjectLoading());
    final result = await getAllProjects();
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (projects) => emit(ProjectsLoaded(projects)),
    );
  }

  Future<void> addProject(String name, String description) async {
    emit(const ProjectLoading());
    final project = Project(name: name, description: description);
    final result = await createProject(project);
    result.fold((failure) => emit(ProjectError(failure.message)), (_) {
      emit(const ProjectOperationSuccess('Project created successfully'));
      loadProjects();
    });
  }

  Future<void> editProject(Project project) async {
    emit(const ProjectLoading());
    final result = await updateProject(project);
    result.fold((failure) => emit(ProjectError(failure.message)), (_) {
      emit(const ProjectOperationSuccess('Project updated successfully'));
      loadProjects();
    });
  }

  Future<void> removeProject(int id) async {
    emit(const ProjectLoading());
    final result = await deleteProject(id);
    result.fold((failure) => emit(ProjectError(failure.message)), (_) {
      emit(const ProjectOperationSuccess('Project deleted successfully'));
      loadProjects();
    });
  }
}
