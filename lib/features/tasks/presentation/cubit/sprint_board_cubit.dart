import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sprint_board_config.dart';
import '../../domain/usecases/sprint_board_usecases.dart';
import 'sprint_board_state.dart';

class SprintBoardCubit extends Cubit<SprintBoardState> {
  static const localUserId = 'local_user';

  final GetSprintBoardConfig getConfig;
  final SaveSprintBoardConfig saveConfig;

  String _userId = localUserId;
  int? _sprintId;

  SprintBoardCubit({
    required this.getConfig,
    required this.saveConfig,
  }) : super(const SprintBoardInitial());

  Future<void> load({required int sprintId, String? userId}) async {
    final effectiveUserId = userId?.trim().isNotEmpty == true
        ? userId!.trim()
        : localUserId;
    _userId = effectiveUserId;
    _sprintId = sprintId;
    emit(const SprintBoardLoading());
    final result = await getConfig(userId: effectiveUserId, sprintId: sprintId);
    result.fold(
      (failure) => emit(SprintBoardError(failure.message)),
      (config) => emit(SprintBoardLoaded(config)),
    );
  }

  Future<void> setMode(BoardMode mode) async {
    final loaded = state;
    if (loaded is! SprintBoardLoaded) return;
    final config = switch (mode) {
      BoardMode.simple => loaded.config.copyWith(
        mode: BoardMode.simple,
        columns: SprintBoardConfig.simpleColumns,
      ),
      BoardMode.professional => loaded.config.copyWith(
        mode: BoardMode.professional,
        columns: loaded.config.columns.length <= 3
            ? SprintBoardConfig.professionalColumns
            : loaded.config.columns,
      ),
    };
    await _persist(config);
  }

  Future<void> updateConfig(SprintBoardConfig config) => _persist(config);

  Future<void> addColumn(String title, {int? wipLimit}) async {
    final loaded = state;
    if (loaded is! SprintBoardLoaded) return;
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;
    final alreadyExists = loaded.config.columns.any(
      (column) => column.id.toLowerCase() == cleanTitle.toLowerCase(),
    );
    if (alreadyExists) return;
    final column = BoardColumnConfig(
      id: cleanTitle,
      title: cleanTitle,
      wipLimit: wipLimit,
    );
    await _persist(
      loaded.config.copyWith(columns: [...loaded.config.columns, column]),
    );
  }

  Future<void> updateColumn(BoardColumnConfig column) async {
    final loaded = state;
    if (loaded is! SprintBoardLoaded) return;
    await _persist(
      loaded.config.copyWith(
        columns: loaded.config.columns
            .map((item) => item.id == column.id ? column : item)
            .toList(),
      ),
    );
  }

  Future<void> updateFilter(BoardFilter filter) async {
    final loaded = state;
    if (loaded is! SprintBoardLoaded) return;
    await _persist(loaded.config.copyWith(filter: filter));
  }

  Future<void> updateSort({
    required BoardSortField field,
    required SortDirection direction,
  }) async {
    final loaded = state;
    if (loaded is! SprintBoardLoaded) return;
    await _persist(
      loaded.config.copyWith(sortField: field, sortDirection: direction),
    );
  }

  Future<void> _persist(SprintBoardConfig config) async {
    final sprintId = _sprintId;
    if (sprintId == null) return;
    final previousState = state;
    emit(SprintBoardLoaded(config));
    final result = await saveConfig(
      userId: _userId,
      sprintId: sprintId,
      config: config,
    );
    result.fold(
      (failure) {
        if (previousState is SprintBoardLoaded) {
          emit(previousState);
        }
        emit(SprintBoardError(failure.message));
      },
      (_) {},
    );
  }
}
