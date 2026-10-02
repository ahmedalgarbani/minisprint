import '../../domain/entities/sprint.dart';

/// Contract shared by the local (SQLite) and remote (REST) implementations.
abstract class SprintDataSource {
  Future<List<Sprint>> getSprintsByProject(int projectId);
  Future<Sprint> getSprintById(int id);
  Future<Sprint> createSprint(Sprint sprint);
  Future<Sprint> updateSprint(Sprint sprint);

  /// Deletes the sprint. Its tasks move back to the product backlog.
  Future<void> deleteSprint(int id);
}
