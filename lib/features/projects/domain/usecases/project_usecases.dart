import '../../../../core/utils/result.dart';
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

  Future<ApiResult<Project>> call(Project project) {
    return repository.createProject(project);
  }
}

class UpdateProject {
  final ProjectRepository repository;

  UpdateProject(this.repository);

  Future<ApiResult<Project>> call(Project project) {
    return repository.updateProject(project);
  }
}

class DeleteProject {
  final ProjectRepository repository;

  DeleteProject(this.repository);

  Future<ApiResult<void>> call(int id) {
    return repository.deleteProject(id);
  }
}
