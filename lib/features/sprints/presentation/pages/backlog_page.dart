import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/preferences/work_mode.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../projects/presentation/cubit/project_workspace_cubit.dart';
import '../../../projects/presentation/cubit/project_workspace_state.dart';
import '../../../settings/presentation/cubit/theme_settings_cubit.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/task_flows.dart';
import '../../../tasks/presentation/widgets/task_row.dart';
import '../../domain/entities/sprint.dart';
import '../sprint_flows.dart';
import '../widgets/sprint_status_pill.dart';

/// Backlog & sprint planning (Jira backlog / Azure DevOps sprint planning).
class BacklogPage extends StatelessWidget {
  const BacklogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final mode = context.select((ThemeSettingsCubit c) => c.state.workMode);
    return BlocBuilder<ProjectWorkspaceCubit, ProjectWorkspaceState>(
      builder: (context, state) {
        if (state is! WorkspaceLoaded) return const SizedBox.shrink();
        final workspace = state.workspace;
        final key = workspace.projectKey;
        final completed = workspace.completedSprints;
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workspace.project.name, overflow: TextOverflow.ellipsis),
                Text(
                  '$key · ${s.backlog}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => openSprintForm(context),
                icon: const Icon(Icons.add_rounded),
                label: Text(s.addSprint),
              ),
              const SizedBox(width: AppPadding.s),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: context.read<ProjectWorkspaceCubit>().refresh,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                  children: [
                    for (final sprint in workspace.openSprints)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppPadding.m),
                        child: _SprintSection(
                          sprint: sprint,
                          tasks: workspace.tasksInSprint(sprint.id!),
                          projectKey: key,
                          mode: mode,
                        ),
                      ),
                    _BacklogSection(
                      tasks: workspace.backlogTasks,
                      projectKey: key,
                      mode: mode,
                    ),
                    if (completed.isNotEmpty) ...[
                      const SizedBox(height: AppPadding.m),
                      _CompletedSprints(sprints: completed),
                    ],
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'backlog-fab',
            onPressed: () => openTaskForm(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(s.addTask),
          ),
        );
      },
    );
  }
}

final _compactButton = TextButton.styleFrom(
  visualDensity: VisualDensity.compact,
  minimumSize: const Size(0, 36),
  padding: const EdgeInsets.symmetric(horizontal: 8),
);

class _SprintSection extends StatelessWidget {
  final Sprint sprint;
  final List<Task> tasks;
  final String projectKey;
  final WorkMode mode;

  const _SprintSection({
    required this.sprint,
    required this.tasks,
    required this.projectKey,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    final summary = [
      formatDateRange(context, sprint.startDate, sprint.endDate),
      s.itemsCount(tasks.length),
      if (mode.isAdvanced) s.pointsCount(totalStoryPoints(tasks)),
    ].join(' · ');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey('sprint-${sprint.id}'),
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        backgroundColor: theme.colorScheme.surface,
        tilePadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
        childrenPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Flexible(
              child: Text(
                sprint.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(width: AppPadding.s),
            SprintStatusPill(status: sprint.status),
          ],
        ),
        subtitle: Text(summary, style: theme.textTheme.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sprint.isPlanned)
              TextButton(
                style: _compactButton,
                onPressed: () => startSprintFlow(context, sprint),
                child: Text(s.startSprint),
              ),
            if (sprint.isActive)
              TextButton(
                style: _compactButton,
                onPressed: () => completeSprintFlow(context, sprint),
                child: Text(s.completeSprint),
              ),
            PopupMenuButton<VoidCallback>(
              tooltip: s.more,
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: () => openSprintForm(context, sprint: sprint),
                  child: ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(s.editSprint),
                  ),
                ),
                PopupMenuItem(
                  value: () => deleteSprintFlow(context, sprint),
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: Text(s.deleteSprint),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          if (sprint.goal.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(sprint.goal, style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          const Divider(),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppPadding.m),
              child: Text(s.sprintEmpty, style: theme.textTheme.bodySmall),
            )
          else
            _TaskList(tasks: tasks, projectKey: projectKey, mode: mode),
        ],
      ),
    );
  }
}

class _BacklogSection extends StatelessWidget {
  final List<Task> tasks;
  final String projectKey;
  final WorkMode mode;

  const _BacklogSection({
    required this.tasks,
    required this.projectKey,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 8),
            child: Row(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppPadding.s),
                Text(s.productBacklog, style: theme.textTheme.titleSmall),
                const SizedBox(width: AppPadding.s),
                Text(
                  [
                    s.itemsCount(tasks.length),
                    if (mode.isAdvanced) s.pointsCount(totalStoryPoints(tasks)),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppPadding.m),
              child: Text(s.backlogEmpty, style: theme.textTheme.bodySmall),
            )
          else
            _TaskList(tasks: tasks, projectKey: projectKey, mode: mode),
          const Divider(),
          const _QuickAdd(),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final String projectKey;
  final WorkMode mode;

  const _TaskList({
    required this.tasks,
    required this.projectKey,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tasks.length; i++) ...[
          if (i > 0) const Divider(indent: 12, endIndent: 12),
          TaskRow(
            task: tasks[i],
            projectKey: projectKey,
            advanced: mode.isAdvanced,
            onTap: () => openTaskForm(context, task: tasks[i]),
            onMore: () => showTaskMenu(context, tasks[i]),
          ),
        ],
      ],
    );
  }
}

/// Inline "create issue" row (title only), like Jira's backlog quick create.
class _QuickAdd extends StatefulWidget {
  const _QuickAdd();

  @override
  State<_QuickAdd> createState() => _QuickAddState();
}

class _QuickAddState extends State<_QuickAdd> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty || _saving) return;
    final cubit = context.read<ProjectWorkspaceCubit>();
    final loaded = cubit.state;
    if (loaded is! WorkspaceLoaded) return;
    setState(() => _saving = true);
    final failure = await cubit.saveTask(
      Task(projectId: loaded.workspace.project.id!, title: title),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (showOperationResult(context, failure)) {
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Padding(
      padding: const EdgeInsets.all(AppPadding.s),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: !_saving,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: s.quickAddHint,
          prefixIcon: const Icon(Icons.add_rounded),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          filled: false,
          suffixIcon: IconButton(
            tooltip: s.create,
            icon: const Icon(Icons.keyboard_return_rounded),
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}

class _CompletedSprints extends StatelessWidget {
  final List<Sprint> sprints;

  const _CompletedSprints({required this.sprints});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: SectionHeader(
          title: '${s.completedSprints} (${sprints.length})',
          padding: EdgeInsets.zero,
        ),
        children: [
          for (final sprint in sprints)
            ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline_rounded),
              title: Text(sprint.name),
              subtitle: Text(
                formatDateRange(context, sprint.startDate, sprint.endDate),
              ),
              trailing: Text(
                '${sprint.completedTasks}/${sprint.totalTasks}',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
