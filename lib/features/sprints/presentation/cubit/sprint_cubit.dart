import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sprint.dart';
import '../../domain/usecases/sprint_usecases.dart';
import 'sprint_state.dart';

class SprintCubit extends Cubit<SprintState> {
  final GetAllSprints getAllSprints;
  final GetSprintsByProject getSprintsByProject;
  final CreateSprint createSprint;
  final UpdateSprint updateSprint;
  final DeleteSprint deleteSprint;

  SprintCubit({
    required this.getAllSprints,
    required this.getSprintsByProject,
    required this.createSprint,
    required this.updateSprint,
    required this.deleteSprint,
  }) : super(const SprintInitial());

  Future<void> loadAllSprints() async {
    emit(const SprintLoading());
    final result = await getAllSprints();
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (sprints) => emit(SprintsLoaded(sprints)),
    );
  }

  Future<void> loadSprints(int projectId) async {
    emit(const SprintLoading());
    final result = await getSprintsByProject(projectId);
    result.fold(
      (failure) => emit(SprintError(failure.message)),
      (sprints) => emit(SprintsLoaded(sprints)),
    );
  }

  Future<void> addSprint(Sprint sprint) async {
    emit(const SprintLoading());
    final result = await createSprint(sprint);
    result.fold((failure) => emit(SprintError(failure.message)), (_) {
      emit(const SprintOperationSuccess('Sprint created successfully'));
      loadSprints(sprint.projectId);
    });
  }

  Future<void> editSprint(Sprint sprint) async {
    emit(const SprintLoading());
    final result = await updateSprint(sprint);
    result.fold((failure) => emit(SprintError(failure.message)), (_) {
      emit(const SprintOperationSuccess('Sprint updated successfully'));
      loadSprints(sprint.projectId);
    });
  }

  Future<void> removeSprint(int id, int projectId) async {
    emit(const SprintLoading());
    final result = await deleteSprint(id);
    result.fold((failure) => emit(SprintError(failure.message)), (_) {
      emit(const SprintOperationSuccess('Sprint deleted successfully'));
      loadSprints(projectId);
    });
  }
}
