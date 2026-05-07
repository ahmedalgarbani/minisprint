import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../sprints/domain/entities/sprint.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../domain/entities/sprint_board_config.dart';
import '../cubit/sprint_board_cubit.dart';
import '../cubit/sprint_board_state.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/kanban_column.dart';
import 'task_form_page.dart';

class KanbanBoardPage extends StatelessWidget {
  final Sprint sprint;
  const KanbanBoardPage({super.key, required this.sprint});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppAppBar(
        title: sprint.name,
        subtitle: Text(
          s.board,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: theme.primaryColor),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, taskState) {
          if (taskState is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (taskState is TaskError) {
            return _buildTaskError(context, taskState.message);
          }
          if (taskState is TasksLoaded) {
            return BlocBuilder<SprintBoardCubit, SprintBoardState>(
              builder: (context, boardState) {
                final config = boardState is SprintBoardLoaded
                    ? boardState.config
                    : SprintBoardConfig.defaults();
                return Column(
                  children: [
                    _buildBoardToolbar(context, config),
                    if (config.mode == BoardMode.professional)
                      _buildAnalytics(context, taskState.tasks, config),
                    Expanded(
                      child: taskState.tasks.isEmpty
                          ? _buildEmptyState(context)
                          : _buildBoard(context, config, taskState.tasks),
                    ),
                  ],
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildTaskError(BuildContext context, String message) {
    final s = S(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppPadding.m),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<TaskCubit>().loadTasks(sprint.id!),
            child: Text(s.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardToolbar(BuildContext context, SprintBoardConfig config) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppPadding.m,
        AppPadding.m,
        AppPadding.m,
        AppPadding.s,
      ),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<BoardMode>(
              segments: const [
                ButtonSegment(
                  value: BoardMode.simple,
                  icon: Icon(Icons.view_column_outlined),
                  label: Text('Simple'),
                ),
                ButtonSegment(
                  value: BoardMode.professional,
                  icon: Icon(Icons.dashboard_customize_outlined),
                  label: Text('Professional'),
                ),
              ],
              selected: {config.mode},
              onSelectionChanged: (values) {
                context.read<SprintBoardCubit>().setMode(values.first);
              },
            ),
          ),
          if (config.mode == BoardMode.professional) ...[
            const SizedBox(width: AppPadding.s),
            IconButton.filledTonal(
              tooltip: 'Board settings',
              onPressed: () => _showProfessionalSettings(context, config),
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalytics(
    BuildContext context,
    List<Task> tasks,
    SprintBoardConfig config,
  ) {
    final done = tasks.where((task) => task.status == TaskStatus.done).length;
    final high = tasks.where((task) => task.priority == TaskPriority.high).length;
    final active = tasks.where((task) => task.status != TaskStatus.done).length;
    final completion = tasks.isEmpty ? 0 : ((done / tasks.length) * 100).round();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.m),
      child: Row(
        children: [
          _buildMetric(context, 'Done', '$completion%', Icons.insights_rounded),
          _buildMetric(context, 'Active', '$active', Icons.timelapse_rounded),
          _buildMetric(context, 'High', '$high', Icons.flag_rounded),
          _buildMetric(
            context,
            'Columns',
            '${config.columns.where((c) => c.enabled).length}',
            Icons.view_week_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: 116,
      margin: const EdgeInsets.only(right: AppPadding.s, bottom: AppPadding.s),
      padding: const EdgeInsets.all(AppPadding.m),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.primaryColor),
          const SizedBox(width: AppPadding.s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: theme.textTheme.titleMedium),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 80,
            color: theme.disabledColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppPadding.m),
          Text(s.noTasks, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(s.addFirstTask),
          const SizedBox(height: AppPadding.l),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => _showCreateDialog(context),
              child: Text(s.addTask),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(
    BuildContext context,
    SprintBoardConfig config,
    List<Task> tasks,
  ) {
    if (config.mode == BoardMode.simple) {
      return _buildColumnRow(
        context: context,
        columns: SprintBoardConfig.simpleColumns,
        tasks: tasks,
        simpleMode: true,
      );
    }

    final professionalTasks = _applyProfessionalView(tasks, config);
    return ListView(
      padding: const EdgeInsets.only(bottom: AppPadding.m),
      children: TaskPriority.values.map((priority) {
        final laneTasks = professionalTasks
            .where((task) => task.priority == priority)
            .toList();
        return _buildSwimlane(
          context: context,
          title: priority,
          columns: config.columns.where((column) => column.enabled).toList(),
          tasks: laneTasks,
        );
      }).toList(),
    );
  }

  Widget _buildSwimlane({
    required BuildContext context,
    required String title,
    required List<BoardColumnConfig> columns,
    required List<Task> tasks,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppPadding.m,
              AppPadding.s,
              AppPadding.m,
              AppPadding.s,
            ),
            child: Row(
              children: [
                Icon(Icons.layers_outlined, size: 16, color: theme.primaryColor),
                const SizedBox(width: AppPadding.s),
                Text('$title priority', style: theme.textTheme.titleSmall),
                const SizedBox(width: AppPadding.s),
                Text('(${tasks.length})', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: _buildColumnRow(
              context: context,
              columns: columns,
              tasks: tasks,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnRow({
    required BuildContext context,
    required List<BoardColumnConfig> columns,
    required List<Task> tasks,
    bool simpleMode = false,
  }) {
    final boardWidth =
        simpleMode ? MediaQuery.of(context).size.width * 0.85 : 300.0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columns.map((column) {
          return SizedBox(
            width: boardWidth,
            child: KanbanColumn(
              title: column.title,
              status: column.id,
              color: _columnColor(column.id),
              tasks: tasks,
              wipLimit: simpleMode ? null : column.wipLimit,
              simpleMode: simpleMode,
              onTaskTap: (task) => _showEditDialog(context, task),
              onTaskDelete: (task) => _showDeleteDialog(context, task),
              onTaskDropped: (task, status) =>
                  _updateTaskStatus(context, task, status),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Task> _applyProfessionalView(
    List<Task> tasks,
    SprintBoardConfig config,
  ) {
    final filter = config.filter;
    final filtered = tasks.where((task) {
      final matchesPriority = filter.priorities.isEmpty ||
          filter.priorities.contains(task.priority);
      final matchesAssignee = filter.assignee.isEmpty ||
          task.assignee.toLowerCase().contains(filter.assignee.toLowerCase());
      final matchesTag = filter.tag.isEmpty ||
          task.tags.any(
            (tag) => tag.toLowerCase().contains(filter.tag.toLowerCase()),
          );
      return matchesPriority && matchesAssignee && matchesTag;
    }).toList();

    filtered.sort((a, b) {
      final value = switch (config.sortField) {
        BoardSortField.title => a.title.compareTo(b.title),
        BoardSortField.assignee => a.assignee.compareTo(b.assignee),
        BoardSortField.priority => _priorityWeight(a.priority).compareTo(
            _priorityWeight(b.priority),
          ),
      };
      return config.sortDirection == SortDirection.ascending ? value : -value;
    });
    return filtered;
  }

  int _priorityWeight(String priority) {
    return switch (priority) {
      TaskPriority.high => 3,
      TaskPriority.medium => 2,
      TaskPriority.low => 1,
      _ => 0,
    };
  }

  Color _columnColor(String status) {
    return switch (status) {
      TaskStatus.backlog => const Color(0xFF64748B),
      TaskStatus.todo => const Color(0xFF94A3B8),
      TaskStatus.inProgress => const Color(0xFF2563EB),
      TaskStatus.review => const Color(0xFFF59E0B),
      TaskStatus.done => const Color(0xFF10B981),
      _ => const Color(0xFF6366F1),
    };
  }

  void _showProfessionalSettings(
    BuildContext context,
    SprintBoardConfig config,
  ) {
    final titleController = TextEditingController();
    final assigneeController = TextEditingController(
      text: config.filter.assignee,
    );
    final tagController = TextEditingController(text: config.filter.tag);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        var draftFilter = config.filter;
        var draftSortField = config.sortField;
        var draftSortDirection = config.sortDirection;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppPadding.m,
                right: AppPadding.m,
                top: AppPadding.m,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppPadding.m,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Professional board',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppPadding.m),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'New column',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () {
                          context
                              .read<SprintBoardCubit>()
                              .addColumn(titleController.text);
                          titleController.clear();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppPadding.m),
                  ...config.columns.map(
                    (column) => _buildColumnConfigTile(context, column),
                  ),
                  const Divider(height: AppPadding.xl),
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: AppPadding.s,
                    children: TaskPriority.values.map((priority) {
                      final selected = draftFilter.priorities.contains(priority);
                      return FilterChip(
                        label: Text(priority),
                        selected: selected,
                        onSelected: (value) {
                          final priorities = {...draftFilter.priorities};
                          if (value) {
                            priorities.add(priority);
                          } else {
                            priorities.remove(priority);
                          }
                          setSheetState(() {
                            draftFilter = draftFilter.copyWith(priorities: priorities);
                          });
                          context.read<SprintBoardCubit>().updateFilter(draftFilter);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppPadding.s),
                  TextField(
                    controller: assigneeController,
                    decoration: const InputDecoration(
                      labelText: 'Assignee filter',
                    ),
                    onChanged: (value) {
                      draftFilter = draftFilter.copyWith(assignee: value.trim());
                      context.read<SprintBoardCubit>().updateFilter(draftFilter);
                    },
                  ),
                  const SizedBox(height: AppPadding.s),
                  TextField(
                    controller: tagController,
                    decoration: const InputDecoration(labelText: 'Tag filter'),
                    onChanged: (value) {
                      draftFilter = draftFilter.copyWith(tag: value.trim());
                      context.read<SprintBoardCubit>().updateFilter(draftFilter);
                    },
                  ),
                  const Divider(height: AppPadding.xl),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<BoardSortField>(
                          value: draftSortField,
                          decoration: const InputDecoration(
                            labelText: 'Sort by',
                          ),
                          items: BoardSortField.values
                              .map(
                                (field) => DropdownMenuItem(
                                  value: field,
                                  child: Text(field.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setSheetState(() => draftSortField = value);
                            context.read<SprintBoardCubit>().updateSort(
                                  field: value,
                                  direction: draftSortDirection,
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: AppPadding.s),
                      Expanded(
                        child: DropdownButtonFormField<SortDirection>(
                          value: draftSortDirection,
                          decoration: const InputDecoration(
                            labelText: 'Direction',
                          ),
                          items: SortDirection.values
                              .map(
                                (direction) => DropdownMenuItem(
                                  value: direction,
                                  child: Text(direction.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setSheetState(() => draftSortDirection = value);
                            context.read<SprintBoardCubit>().updateSort(
                                  field: draftSortField,
                                  direction: value,
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      assigneeController.dispose();
      tagController.dispose();
    });
  }

  Widget _buildColumnConfigTile(
    BuildContext context,
    BoardColumnConfig column,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.s),
      child: Row(
        children: [
          Switch(
            value: column.enabled,
            onChanged: (value) {
              context
                  .read<SprintBoardCubit>()
                  .updateColumn(column.copyWith(enabled: value));
            },
          ),
          Expanded(child: Text(column.title)),
          SizedBox(
            width: 92,
            child: TextFormField(
              initialValue: column.wipLimit?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'WIP'),
              onFieldSubmitted: (value) {
                context.read<SprintBoardCubit>().updateColumn(
                      column.copyWith(
                        wipLimit: int.tryParse(value),
                        clearWipLimit: value.trim().isEmpty,
                      ),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<TaskCubit>(),
        child: TaskFormPage(sprintId: sprint.id!),
      ),
    ),
  );

  void _showEditDialog(BuildContext context, Task task) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<TaskCubit>(),
        child: TaskFormPage(sprintId: sprint.id!, task: task),
      ),
    ),
  );

  void _showDeleteDialog(BuildContext context, Task task) {
    final s = S(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.deleteTask),
        content: Text(s.deleteConfirmTask),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TaskCubit>().removeTask(task.id!, sprint.id!);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }

  void _updateTaskStatus(BuildContext context, Task task, String status) {
    context.read<TaskCubit>().updateTaskStatus(task, status);
  }
}
