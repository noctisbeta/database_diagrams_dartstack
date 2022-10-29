import 'package:database_diagrams/collections/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Collection store.
class CollectionStore extends StateNotifier<List<Collection>> {
  /// Default constructor.
  CollectionStore() : super(const []);

  /// Provider.
  static final provider = StateNotifierProvider<CollectionStore, List<Collection>>(
    (ref) {
      return CollectionStore();
    },
  );

  /// Add collection.
  void add(Collection collection) {
    state = [...state, collection];
  }

  /// Remove collection.
  void remove(Collection collection) {
    state = state.where((c) => c != collection).toList();
  }
}
