import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/preferences/work_mode.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../projects/domain/entities/project_workspace.dart';
import '../../../projects/presentation/cubit/project_workspace_cubit.dart';
import '../../../projects/presentation/cubit/project_workspace_state.dart';
import '../../../settings/presentation/cubit/theme_settings_cubit.dart';
import '../../../sprints/domain/entities/sprint.dart';
import '../../../sprints/presentation/sprint_flows.dart';
import '../../../sprints/presentation/widgets/sprint_selector.dart';
import '../cubit/board_cubit.dart';
import '../cubit/board_state.dart';
import '../task_flows.dart';
import '../widgets/board_filter_sheet.dart';
import '../widgets/board_layout.dart';
import '../widgets/board_settings_sheet.dart';

/// Sprint board (Jira board / Azure DevOps taskboard).
class BoardPage extends StatelessWidget {
  final VoidCallback onOpenBacklog;

  const BoardPage({super.key, required this.onOpenBacklog});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final mode = context.select((ThemeSettingsCubit c) => c.state.workMode);
    return BlocBuilder<ProjectWorkspaceCubit, ProjectWorkspaceState>(
      builder: (context, state) {
        if (state is! WorkspaceLoaded) return const SizedBox.shrink();
        final workspace = state.workspace;
        final sprint = state.selectedSprint;
        return Scaffold(
          appBar: AppBar(
            title: SprintSelector(
              selected: sprint,
              sprints: workspace.sprints,
              fallbackTitle: s.board,
              onSelected: (picked) => context
                  .read<ProjectWorkspaceCubit>()
                  .selectSprint(picked.id!),
            ),
            actions: [
              if (sprint != null && mode.isAdvanced) ...[
                const _FilterButton(),
                IconButton(
                  tooltip: s.boardSettings,
                  onPressed: () => showBoardSettingsSheet(context),
                  icon: const Icon(Icons.view_week_outlined),
                ),
              ],
              if (sprint != null) _SprintMenu(sprint: sprint),
            ],
          ),
          body: sprint == null
              ? EmptyStateView(
                  icon: Icons.view_kanban_outlined,
                  title: s.noActiveSprint,
                  message: s.noActiveSprintHint,
                  actionLabel: s.goToBacklog,
                  actionIcon: Icons.list_alt_rounded,
                  onAction: onOpenBacklog,
                )
              : Column(
                  children: [
                    _SprintHeader(sprint: sprint),
                    const _SearchBar(),
                    Expanded(
                      child: _Board(
                        workspace: workspace,
                        sprint: sprint,
                        mode: mode,
                      ),
                    ),
                  ],
                ),
          floatingActionButton: sprint == null || sprint.isCompleted
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'board-fab',
                  onPressed: () => openTaskForm(context, sprintId: sprint.id),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(s.addTask),
                ),
        );
      },
    );
  }
}

class _Board extends StatelessWidget {
  final ProjectWorkspace workspace;
  final Sprint sprint;
  final WorkMode mode;

  const _Board({
    required this.workspace,
    required this.sprint,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return BlocBuilder<BoardCubit, BoardState>(
      builder: (context, boardState) {
        final cubit = context.read<BoardCubit>();
        final view = cubit.view(
          tasks: workspace.tasksInSprint(sprint.id!),
          mode: mode,
          projectKey: workspace.projectKey,
        );
        if (view.totalCount == 0) {
          return EmptyStateView(
            icon: Icons.inbox_outlined,
            title: s.noTasks,
            message: s.sprintEmpty,
            actionLabel: s.addTask,
            onAction: sprint.isCompleted
                ? null
                : () => openTaskForm(context, sprintId: sprint.id),
          );
        }
        if (view.visibleCount == 0) {
          return EmptyStateView(
            icon: Icons.filter_alt_off_outlined,
            title: s.noMatches,
            actionLabel: s.clearFilters,
            actionIcon: Icons.clear_all_rounded,
            onAction: cubit.clearFilters,
          );
        }
        return BoardLayout(
          view: view,
          projectKey: workspace.projectKey,
          advanced: mode.isAdvanced,
          onTaskTap: (task) => openTaskForm(context, task: task),
          onTaskMore: (task) => showTaskMenu(context, task),
          onDrop: (task, status) async {
            final failure = await context
                .read<ProjectWorkspaceCubit>()
                .changeStatus(task, status);
            if (context.mounted) showOperationResult(context, failure);
          },
        );
      },
    );
  }
}

class _SprintHeader extends StatelessWidget {
  final Sprint sprint;

  const _SprintHeader({required this.sprint});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sprint.goal.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    sprint.goal,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: sprint.progress,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${sprint.completedTasks}/${sprint.totalTasks} · ${(sprint.progress * 100).round()}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (sprint.isPlanned) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(s.notStarted, style: theme.textTheme.bodySmall),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => startSprintFlow(context, sprint),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(s.startSprint),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<BoardCubit>().state.query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return BlocListener<BoardCubit, BoardState>(
      listenWhen: (a, b) => a.query != b.query && b.query != _controller.text,
      listener: (context, state) => _controller.text = state.query,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppPadding.m,
          AppPadding.s,
          AppPadding.m,
          0,
        ),
        child: TextField(
          controller: _controller,
          onChanged: context.read<BoardCubit>().setQuery,
          decoration: InputDecoration(
            hintText: s.searchBoard,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: s.clear,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _controller.clear();
                        context.read<BoardCubit>().setQuery('');
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton();

  @override
  Widget build(BuildContext context) {
    final count = context.select(
      (BoardCubit c) => c.state.config.filter.activeCount,
    );
    return IconButton(
      tooltip: S(context).filters,
      onPressed: () => showBoardFilterSheet(context),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.filter_list_rounded),
      ),
    );
  }
}

class _SprintMenu extends StatelessWidget {
  final Sprint sprint;

  const _SprintMenu({required this.sprint});

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return PopupMenuButton<VoidCallback>(
      tooltip: s.more,
      onSelected: (action) => action(),
      itemBuilder: (_) => [
        if (sprint.isPlanned)
          PopupMenuItem(
            value: () => startSprintFlow(context, sprint),
            child: ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: Text(s.startSprint),
            ),
          ),
        if (sprint.isActive)
          PopupMenuItem(
            value: () => completeSprintFlow(context, sprint),
            child: ListTile(
              leading: const Icon(Icons.done_all_rounded),
              title: Text(s.completeSprint),
            ),
          ),
        PopupMenuItem(
          value: () => openSprintForm(context, sprint: sprint),
          child: ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(s.editSprint),
          ),
        ),
      ],
    );
  }
}
