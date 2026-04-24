import '../../../../core/utils/result.dart';
import '../entities/sprint.dart';
import '../repositories/sprint_repository.dart';

class GetAllSprints {
  final SprintRepository repository;

  GetAllSprints(this.repository);

  Future<ApiResult<List<Sprint>>> call() {
    return repository.getAllSprints();
  }
}

 class GetSprintsByProject {
  final SprintRepository repository;

  GetSprintsByProject(this.repository);

  Future<ApiResult<List<Sprint>>> call(int projectId) {
    return repository.getSprintsByProject(projectId);
  }
}

class GetSprintById {
  final SprintRepository repository;

  GetSprintById(this.repository);

  Future<ApiResult<Sprint>> call(int id) {
    return repository.getSprintById(id);
  }
}

class CreateSprint {
  final SprintRepository repository;

  CreateSprint(this.repository);

  Future<ApiResult<Sprint>> call(Sprint sprint) {
    return repository.createSprint(sprint);
  }
}

class UpdateSprint {
  final SprintRepository repository;

  UpdateSprint(this.repository);

  Future<ApiResult<Sprint>> call(Sprint sprint) {
    return repository.updateSprint(sprint);
  }
}

class DeleteSprint {
  final SprintRepository repository;

  DeleteSprint(this.repository);

  Future<ApiResult<void>> call(int id) {
    return repository.deleteSprint(id);
  }
}
