class AppPadding {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

class AppConstants {
  static const String appName = 'MiniSprint';
  static const double defaultElevation = 0.0;

  // Database
  static const String databaseName = 'minisprint.db';
  static const int databaseVersion = 2;
  static const String tableProjects = 'projects';
  static const String tableSprints = 'sprints';
  static const String tableTasks = 'tasks';
}

class TaskStatus {
  static const String backlog = 'Backlog';
  static const String todo = 'To Do';
  static const String inProgress = 'In Progress';
  static const String review = 'Review';
  static const String done = 'Done';
  
  static const List<String> values = [backlog, todo, inProgress, review, done];
}

class TaskPriority {
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';
  
  static const List<String> values = [low, medium, high];
}
