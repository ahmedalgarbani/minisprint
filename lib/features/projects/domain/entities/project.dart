import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final int? id;
  final String name;
  final String description;

  /// Short prefix used for work item keys, e.g. `MOB` in `MOB-12`.
  final String key;
  final int sprintCount;
  final int taskCount;

  const Project({
    this.id,
    required this.name,
    required this.description,
    this.key = '',
    this.sprintCount = 0,
    this.taskCount = 0,
  });

  /// The explicit [key] or one derived from [name].
  String get displayKey =>
      key.trim().isNotEmpty ? key.trim().toUpperCase() : deriveKey(name);

  /// `Mobile Banking App` → `MBA`, `Website` → `WEB`.
  static String deriveKey(String name) {
    final words = name
        .trim()
        .split(RegExp(r'[\s_\-]+'))
        .map((w) => w.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), ''))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'PRJ';
    if (words.length == 1) {
      final word = words.first;
      return word.substring(0, word.length < 3 ? word.length : 3).toUpperCase();
    }
    return words.take(4).map((w) => w[0]).join().toUpperCase();
  }

  Project copyWith({
    int? id,
    String? name,
    String? description,
    String? key,
    int? sprintCount,
    int? taskCount,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      key: key ?? this.key,
      sprintCount: sprintCount ?? this.sprintCount,
      taskCount: taskCount ?? this.taskCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    key,
    sprintCount,
    taskCount,
  ];
}
