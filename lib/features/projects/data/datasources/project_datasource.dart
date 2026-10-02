import '../../domain/entities/project.dart';

/// Contract shared by the local (SQLite) and remote (REST) implementations.
/// Implementations throw [AppException]s; the repository maps them to
/// failures.
abstract class ProjectDataSource {
  Future<List<Project>> getAllProjects();
  Future<Project> getProjectById(int id);
  Future<Project> createProject(Project project);
  Future<Project> updateProject(Project project);
  Future<void> deleteProject(int id);
}
