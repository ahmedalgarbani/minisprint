import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_helper.dart';
import '../../domain/entities/board_config.dart';
import '../cubit/board_cubit.dart';
import '../cubit/board_state.dart';
import 'board_layout.dart';

/// Column management: show/hide, reorder, WIP limits and custom columns.
Future<void> showBoardSettingsSheet(BuildContext context) {
  final cubit = context.read<BoardCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _BoardSettingsSheet()),
  );
}

class _BoardSettingsSheet extends StatefulWidget {
  const _BoardSettingsSheet();

  @override
  State<_BoardSettingsSheet> createState() => _BoardSettingsSheetState();
}

class _BoardSettingsSheetState extends State<_BoardSettingsSheet> {
  final _newColumn = TextEditingController();

  @override
  void dispose() {
    _newColumn.dispose();
    super.dispose();
  }

  void _add(BoardCubit cubit) {
    cubit.addColumn(_newColumn.text);
    _newColumn.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final theme = Theme.of(context);
    return BlocBuilder<BoardCubit, BoardState>(
      builder: (context, state) {
        final cubit = context.read<BoardCubit>();
        final columns = state.config.columns;
        final enabledCount = columns.where((c) => c.enabled).length;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.boardSettings,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: cubit.resetColumns,
                          child: Text(s.reset),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      buildDefaultDragHandles: false,
                      itemCount: columns.length,
                      // onReorderItem needs Flutter 3.41+; keep onReorder for
                      // the SDK range declared in pubspec.yaml.
                      // ignore: deprecated_member_use
                      onReorder: (from, to) =>
                          cubit.moveColumn(from, to > from ? to - 1 : to),
                      itemBuilder: (context, index) {
                        final column = columns[index];
                        final custom = !TaskStatus.values.contains(column.id);
                        return ListTile(
                          key: ValueKey(column.id),
                          contentPadding: const EdgeInsetsDirectional.only(
                            start: 4,
                            end: 8,
                          ),
                          leading: ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.drag_indicator_rounded),
                            ),
                          ),
                          title: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: AppColors.statusColor(column.id),
                              ),
                              const SizedBox(width: 8),
                              Flexible(child: Text(columnTitle(s, column))),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 64,
                                child: _WipField(
                                  key: ValueKey('wip-${column.id}'),
                                  column: column,
                                  label: s.wipLimit,
                                  onChanged: cubit.updateColumn,
                                ),
                              ),
                              Switch(
                                value: column.enabled,
                                // Never allow hiding the last visible column.
                                onChanged: column.enabled && enabledCount == 1
                                    ? null
                                    : (on) => cubit.updateColumn(
                                        column.copyWith(enabled: on),
                                      ),
                              ),
                              if (custom)
                                IconButton(
                                  tooltip: s.delete,
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: enabledCount == 1 && column.enabled
                                      ? null
                                      : () => cubit.removeColumn(column.id),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppPadding.m),
                    child: TextField(
                      controller: _newColumn,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: s.addColumn,
                        hintText: s.columnName,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add_rounded),
                          onPressed: () => _add(cubit),
                        ),
                      ),
                      onSubmitted: (_) => _add(cubit),
                    ),
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

class _WipField extends StatelessWidget {
  final BoardColumnConfig column;
  final String label;
  final ValueChanged<BoardColumnConfig> onChanged;

  const _WipField({
    super.key,
    required this.column,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: column.wipLimit?.toString() ?? '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(fontSize: 10),
      ),
      onFieldSubmitted: (value) => _submit(value),
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onChanged: _submit,
    );
  }

  void _submit(String value) {
    final limit = int.tryParse(value);
    if (limit == column.wipLimit) return;
    onChanged(
      limit == null || limit <= 0
          ? column.copyWith(clearWipLimit: true)
          : column.copyWith(wipLimit: limit),
    );
  }
}
