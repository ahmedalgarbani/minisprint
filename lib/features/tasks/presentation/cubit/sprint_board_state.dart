import 'package:equatable/equatable.dart';

import '../../domain/entities/sprint_board_config.dart';

sealed class SprintBoardState extends Equatable {
  const SprintBoardState();

  @override
  List<Object?> get props => [];
}

class SprintBoardInitial extends SprintBoardState {
  const SprintBoardInitial();
}

class SprintBoardLoading extends SprintBoardState {
  const SprintBoardLoading();
}

class SprintBoardLoaded extends SprintBoardState {
  final SprintBoardConfig config;

  const SprintBoardLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class SprintBoardError extends SprintBoardState {
  final String message;

  const SprintBoardError(this.message);

  @override
  List<Object?> get props => [message];
}
