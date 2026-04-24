import 'package:equatable/equatable.dart';
import '../../domain/entities/sprint.dart';

sealed class SprintState extends Equatable {
  const SprintState();

  @override
  List<Object?> get props => [];
}

class SprintInitial extends SprintState {
  const SprintInitial();
}

class SprintLoading extends SprintState {
  const SprintLoading();
}

class SprintsLoaded extends SprintState {
  final List<Sprint> sprints;

  const SprintsLoaded(this.sprints);

  @override
  List<Object?> get props => [sprints];
}

class SprintOperationSuccess extends SprintState {
  final String message;

  const SprintOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SprintError extends SprintState {
  final String message;

  const SprintError(this.message);

  @override
  List<Object?> get props => [message];
}
