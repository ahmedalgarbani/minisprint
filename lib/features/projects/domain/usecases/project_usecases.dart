import '../../../../core/utils/result.dart';
import '../../../../core/utils/validation.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetAllProjects {
  final ProjectRepository repository;

  GetAllProjects(this.repository);

  Future<ApiResult<List<Project>>> call() {
    return repository.getAllProjects();
  }
}

class GetProjectById {
  final ProjectRepository repository;

  GetProjectById(this.repository);

  Future<ApiResult<Project>> call(int id) {
    return repository.getProjectById(id);
  }
}

class CreateProject {
  final ProjectRepository repository;

  CreateProject(this.repository);

  Future<ApiResult<Project>> call(Project project) async {
    final clean = _normalize(project);
    if (clean.name.isEmpty) return invalid(ValidationCodes.requiredName);
    return repository.createProject(clean);
  }
}

class UpdateProject {
  final ProjectRepository repository;

  UpdateProject(this.repository);

  Future<ApiResult<Project>> call(Project project) async {
    final clean = _normalize(project);
    if (clean.name.isEmpty) return invalid(ValidationCodes.requiredName);
    return repository.updateProject(clean);
  }
}

class DeleteProject {
  final ProjectRepository repository;

  DeleteProject(this.repository);

  Future<ApiResult<void>> call(int id) {
    return repository.deleteProject(id);
  }
}

Project _normalize(Project project) => project.copyWith(
  name: project.name.trim(),
  description: project.description.trim(),
  key: project.key.trim().toUpperCase(),
);
