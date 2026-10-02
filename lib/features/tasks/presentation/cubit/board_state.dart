import 'package:equatable/equatable.dart';

import '../../domain/entities/board_config.dart';

class BoardState extends Equatable {
  final BoardConfig config;

  /// Free-text search; not persisted.
  final String query;
  final bool isLoaded;

  const BoardState({
    this.config = const BoardConfig(),
    this.query = '',
    this.isLoaded = false,
  });

  BoardState copyWith({BoardConfig? config, String? query, bool? isLoaded}) {
    return BoardState(
      config: config ?? this.config,
      query: query ?? this.query,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [config, query, isLoaded];
}
