import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/string_helper.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/board_config.dart';
import '../../domain/entities/task.dart';
import '../cubit/board_cubit.dart';
import '../cubit/board_state.dart';
import 'work_item_visuals.dart';

/// Advanced-mode filters, swimlanes and sorting. Changes apply live.
Future<void> showBoardFilterSheet(BuildContext context) {
  final cubit = context.read<BoardCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _BoardFilterSheet()),
  );
}

class _BoardFilterSheet extends StatefulWidget {
  const _BoardFilterSheet();

  @override
  State<_BoardFilterSheet> createState() => _BoardFilterSheetState();
}

class _BoardFilterSheetState extends State<_BoardFilterSheet> {
  late final TextEditingController _assignee;
  late final TextEditingController _tag;

  @override
  void initState() {
    super.initState();
    final filter = context.read<BoardCubit>().state.config.filter;
    _assignee = TextEditingController(text: filter.assignee);
    _tag = TextEditingController(text: filter.tag);
  }

  @override
  void dispose() {
    _assignee.dispose();
    _tag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return BlocBuilder<BoardCubit, BoardState>(
      builder: (context, state) {
        final cubit = context.read<BoardCubit>();
        final config = state.config;
        final filter = config.filter;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.85,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.filters,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: filter.isEmpty
                            ? null
                            : () {
                                _assignee.clear();
                                _tag.clear();
                                cubit.setFilter(const BoardFilter());
                              },
                        child: Text(s.clearFilters),
                      ),
                    ],
                  ),
                  SectionHeader(title: s.type),
                  Wrap(
                    spacing: AppPadding.s,
                    runSpacing: AppPadding.s,
                    children: [
                      for (final type in WorkItemType.values)
                        FilterChip(
                          avatar: WorkItemTypeIcon(type: type),
                          label: Text(s.typeLabel(type.name)),
                          selected: filter.types.contains(type),
                          onSelected: (on) => cubit.setFilter(
                            filter.copyWith(
                              types: on
                                  ? {...filter.types, type}
                                  : ({...filter.types}..remove(type)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SectionHeader(title: s.priority),
                  Wrap(
                    spacing: AppPadding.s,
                    runSpacing: AppPadding.s,
                    children: [
                      for (final priority in TaskPriority.values.reversed)
                        FilterChip(
                          avatar: PriorityIcon(priority: priority, size: 16),
                          label: Text(s.priorityLabel(priority)),
                          selected: filter.priorities.contains(priority),
                          onSelected: (on) => cubit.setFilter(
                            filter.copyWith(
                              priorities: on
                                  ? {...filter.priorities, priority}
                                  : ({...filter.priorities}..remove(priority)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppPadding.m),
                  TextField(
                    controller: _assignee,
                    decoration: InputDecoration(
                      labelText: s.assignee,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    onChanged: (v) =>
                        cubit.setFilter(filter.copyWith(assignee: v.trim())),
                  ),
                  const SizedBox(height: AppPadding.s),
                  TextField(
                    controller: _tag,
                    decoration: InputDecoration(
                      labelText: s.tags,
                      prefixIcon: const Icon(Icons.sell_outlined),
                    ),
                    onChanged: (v) =>
                        cubit.setFilter(filter.copyWith(tag: v.trim())),
                  ),
                  SectionHeader(title: s.groupBy),
                  SegmentedButton<BoardGrouping>(
                    showSelectedIcon: false,
                    segments: [
                      for (final g in BoardGrouping.values)
                        ButtonSegment(
                          value: g,
                          label: Text(s.groupingLabel(g.name)),
                        ),
                    ],
                    selected: {config.grouping},
                    onSelectionChanged: (v) => cubit.setGrouping(v.first),
                  ),
                  SectionHeader(title: s.sortBy),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<BoardSortField>(
                          initialValue: config.sortField,
                          items: [
                            for (final f in BoardSortField.values)
                              DropdownMenuItem(
                                value: f,
                                child: Text(s.sortLabel(f.name)),
                              ),
                          ],
                          onChanged: (f) {
                            if (f != null) {
                              cubit.setSort(f, config.sortDirection);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppPadding.s),
                      IconButton.outlined(
                        tooltip: config.sortDirection == SortDirection.ascending
                            ? s.ascending
                            : s.descending,
                        onPressed: () => cubit.setSort(
                          config.sortField,
                          config.sortDirection == SortDirection.ascending
                              ? SortDirection.descending
                              : SortDirection.ascending,
                        ),
                        icon: Icon(
                          config.sortDirection == SortDirection.ascending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
