import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/preferences/work_mode.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/board_config.dart';
import '../../domain/entities/board_view.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/board_config_usecases.dart';
import '../../domain/usecases/build_board_view.dart';
import 'board_state.dart';

/// Board settings (columns, filters, swimlanes) for one project.
class BoardCubit extends Cubit<BoardState> {
  final GetBoardConfig getConfig;
  final SaveBoardConfig saveConfig;
  final BuildBoardView buildBoardView;

  int? _projectId;

  // Memoized last view so rebuilding widgets do not recompute it.
  (List<Task>, BoardState, WorkMode, String)? _lastInput;
  BoardView? _lastView;

  BoardCubit({
    required this.getConfig,
    required this.saveConfig,
    required this.buildBoardView,
  }) : super(const BoardState());

  Future<void> load(int projectId) async {
    _projectId = projectId;
    final result = await getConfig(projectId);
    if (isClosed) return;
    emit(
      state.copyWith(
        config: result.dataOrNull ?? const BoardConfig(),
        isLoaded: true,
      ),
    );
  }

  BoardView view({
    required List<Task> tasks,
    required WorkMode mode,
    required String projectKey,
  }) {
    final input = (tasks, state, mode, projectKey);
    final last = _lastInput;
    if (last != null &&
        listEquals(last.$1, tasks) &&
        last.$2 == state &&
        last.$3 == mode &&
        last.$4 == projectKey) {
      return _lastView!;
    }
    _lastInput = input;
    return _lastView = buildBoardView(
      tasks: tasks,
      config: state.config,
      mode: mode,
      query: state.query,
      projectKey: projectKey,
    );
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  Future<void> setFilter(BoardFilter filter) =>
      _persist(state.config.copyWith(filter: filter));

  Future<void> clearFilters() async {
    emit(state.copyWith(query: ''));
    await _persist(state.config.copyWith(filter: const BoardFilter()));
  }

  Future<void> setGrouping(BoardGrouping grouping) =>
      _persist(state.config.copyWith(grouping: grouping));

  Future<void> setSort(BoardSortField field, SortDirection direction) =>
      _persist(
        state.config.copyWith(sortField: field, sortDirection: direction),
      );

  /// Adds a custom column; its title becomes the task status it represents.
  Future<void> addColumn(String title, {int? wipLimit}) async {
    final clean = title.trim();
    if (clean.isEmpty) return;
    final exists = state.config.columns.any(
      (c) => c.id.toLowerCase() == clean.toLowerCase(),
    );
    if (exists) return;
    final columns = [...state.config.columns];
    // Keep "Done" last so the workflow still reads left to right.
    final doneIndex = columns.lastIndexWhere((c) => c.id == 'Done');
    columns.insert(
      doneIndex == -1 ? columns.length : doneIndex,
      BoardColumnConfig(id: clean, title: clean, wipLimit: wipLimit),
    );
    await _persist(state.config.copyWith(columns: columns));
  }

  Future<void> updateColumn(BoardColumnConfig column) => _persist(
    state.config.copyWith(
      columns: [
        for (final c in state.config.columns) c.id == column.id ? column : c,
      ],
    ),
  );

  Future<void> removeColumn(String id) async {
    final columns = state.config.columns.where((c) => c.id != id).toList();
    if (columns.isEmpty) return;
    await _persist(state.config.copyWith(columns: columns));
  }

  Future<void> moveColumn(int oldIndex, int newIndex) async {
    final columns = [...state.config.columns];
    final column = columns.removeAt(oldIndex);
    columns.insert(newIndex.clamp(0, columns.length), column);
    await _persist(state.config.copyWith(columns: columns));
  }

  Future<void> resetColumns() =>
      _persist(state.config.copyWith(columns: BoardConfig.advancedColumns));

  /// Settings apply immediately; saving is best-effort (a view preference
  /// failing to persist must not block work).
  Future<void> _persist(BoardConfig config) async {
    emit(state.copyWith(config: config));
    final projectId = _projectId;
    if (projectId != null) await saveConfig(projectId, config);
  }
}
