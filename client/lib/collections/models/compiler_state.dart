/// Compiler state.
class CompilerState {
  /// Default constructor.
  const CompilerState({
    required this.collections,
    required this.relations,
  });

  /// Initial state.
  const CompilerState.initial()
      : collections = '',
        relations = '';

  /// Collections.
  final String collections;

  /// Relations.
  final String relations;

  /// Copy with.
  CompilerState copyWith({
    String? collections,
    String? relations,
  }) {
    return CompilerState(
      collections: collections ?? this.collections,
      relations: relations ?? this.relations,
    );
  }
}
