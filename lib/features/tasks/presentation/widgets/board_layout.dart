import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/avatar_initials.dart';
import '../../domain/entities/board_config.dart';
import '../../domain/entities/board_view.dart';
import '../../domain/entities/task.dart';
import 'task_card.dart';
import 'work_item_visuals.dart';

String columnTitle(S s, BoardColumnConfig column) =>
    TaskStatus.values.contains(column.id)
    ? s.statusLabel(column.id)
    : column.title;

/// Kanban board: columns side by side, optionally split into swimlanes.
/// Columns fill the width on large screens and scroll horizontally on phones.
class BoardLayout extends StatelessWidget {
  static const double minColumnWidth = 260;
  static const double phoneColumnWidth = 280;
  static const double _gutter = AppPadding.s;

  final BoardView view;
  final String projectKey;
  final bool advanced;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onTaskMore;
  final void Function(Task task, String columnId) onDrop;

  const BoardLayout({
    super.key,
    required this.view,
    required this.projectKey,
    required this.advanced,
    required this.onTaskTap,
    required this.onTaskMore,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = view.columns.length;
        final available = constraints.maxWidth - _gutter * 2;
        final fits = count > 0 && available / count >= minColumnWidth;
        final columnWidth = fits ? available / count : phoneColumnWidth;
        final grouped = view.grouping != BoardGrouping.none;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: SizedBox(
            width: columnWidth * count,
            height: constraints.maxHeight,
            child: grouped
                ? _buildLanes(context, columnWidth)
                : _buildColumns(context, columnWidth),
          ),
        );
      },
    );
  }

  Widget _buildColumns(BuildContext context, double width) {
    final lane = view.lanes.first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final column in view.columns)
          SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _ColumnPanel(
                header: _ColumnHeader(column: column, view: view),
                child: _DropCell(
                  column: column,
                  onDrop: onDrop,
                  expand: true,
                  child: _cards(
                    context,
                    lane.cells[column.id]!,
                    width,
                    scrollable: true,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLanes(BuildContext context, double width) {
    final s = S(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            for (final column in view.columns)
              SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _ColumnHeader(
                    column: column,
                    view: view,
                    standalone: true,
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final lane in view.lanes) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 16, 8, 6),
                  child: Row(
                    children: [
                      _laneIcon(lane),
                      const SizedBox(width: 8),
                      Text(
                        _laneTitle(s, lane),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(width: 6),
                      Text('(${lane.count})', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final column in view.columns)
                      SizedBox(
                        width: width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _DropCell(
                            column: column,
                            onDrop: onDrop,
                            child: _cards(
                              context,
                              lane.cells[column.id]!,
                              width,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _laneIcon(BoardLane lane) => switch (view.grouping) {
    BoardGrouping.priority => PriorityIcon(priority: lane.value),
    BoardGrouping.type => WorkItemTypeIcon(
      type: WorkItemType.fromValue(lane.value),
    ),
    BoardGrouping.assignee => AvatarInitials(name: lane.value, size: 20),
    BoardGrouping.none => const SizedBox.shrink(),
  };

  String _laneTitle(S s, BoardLane lane) => switch (view.grouping) {
    BoardGrouping.priority => s.priorityLabel(lane.value),
    BoardGrouping.type => s.typeLabel(lane.value),
    BoardGrouping.assignee => lane.value.isEmpty ? s.unassigned : lane.value,
    BoardGrouping.none => '',
  };

  Widget _cards(
    BuildContext context,
    List<Task> tasks,
    double width, {
    bool scrollable = false,
  }) {
    Widget card(Task task) => Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.s),
      child: _DraggableCard(
        task: task,
        width: width - 24,
        projectKey: projectKey,
        advanced: advanced,
        onTap: () => onTaskTap(task),
        onMore: () => onTaskMore(task),
      ),
    );
    if (!scrollable) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Column(children: [for (final t in tasks) card(t)]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 88),
      itemCount: tasks.length,
      itemBuilder: (context, index) => card(tasks[index]),
    );
  }
}

class _ColumnPanel extends StatelessWidget {
  final Widget header;
  final Widget child;

  const _ColumnPanel({required this.header, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppPadding.s),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Column(
        children: [
          header,
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final BoardColumnConfig column;
  final BoardView view;
  final bool standalone;

  const _ColumnHeader({
    required this.column,
    required this.view,
    this.standalone = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    final count = view.countFor(column.id);
    final over = view.isOverWipLimit(column);
    final color = AppColors.statusColor(column.id);
    final countText = column.wipLimit == null
        ? '$count'
        : '$count / ${column.wipLimit}';
    return Container(
      margin: standalone ? const EdgeInsets.only(top: AppPadding.s) : null,
      padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: standalone
            ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6)
            : null,
        borderRadius: standalone ? BorderRadius.circular(AppRadius.s) : null,
        border: Border(
          top: BorderSide(color: over ? AppColors.error : color, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              columnTitle(s, column).toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 0.4),
            ),
          ),
          if (over)
            Tooltip(
              message: s.wipExceeded,
              child: const Padding(
                padding: EdgeInsetsDirectional.only(end: 4),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
            ),
          Text(
            countText,
            style: theme.textTheme.labelMedium?.copyWith(
              color: over ? AppColors.error : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropCell extends StatelessWidget {
  final BoardColumnConfig column;
  final void Function(Task task, String columnId) onDrop;
  final Widget child;
  final bool expand;

  const _DropCell({
    required this.column,
    required this.onDrop,
    required this.child,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != column.id,
      onAcceptWithDetails: (details) => onDrop(details.data, column.id),
      builder: (context, candidates, _) {
        final active = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: BoxConstraints(minHeight: expand ? 0 : 64),
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primaryContainer
                : expand
                ? null
                : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppRadius.s),
            border: Border.all(
              color: active ? theme.colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

/// Long-press to drag, so normal swipes still scroll the board on touch
/// screens.
class _DraggableCard extends StatelessWidget {
  final Task task;
  final double width;
  final String projectKey;
  final bool advanced;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const _DraggableCard({
    required this.task,
    required this.width,
    required this.projectKey,
    required this.advanced,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final card = TaskCard(
      task: task,
      projectKey: projectKey,
      advanced: advanced,
      onTap: onTap,
      onMore: onMore,
    );
    return LongPressDraggable<Task>(
      data: task,
      delay: const Duration(milliseconds: 250),
      feedback: Material(
        color: Colors.transparent,
        elevation: 8,
        borderRadius: BorderRadius.circular(AppRadius.m),
        child: SizedBox(
          width: width,
          child: TaskCard(
            task: task,
            projectKey: projectKey,
            advanced: advanced,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }
}
