import 'package:database_diagrams/projects/models/saveable.dart';
import 'package:database_diagrams/smartline/card_ordinal.dart';
import 'package:database_diagrams/smartline/smartline_anchor.dart';
import 'package:database_diagrams/smartline/smartline_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:functional/functional.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// SmartLineController.
class SmartlineController extends ChangeNotifier implements Saveable {
  /// Provider.
  static final provider = ChangeNotifierProvider<SmartlineController>(
    (ref) => SmartlineController(),
  );

  CardOrdinal _cardOrdinal = CardOrdinal.first;

  final List<List<SmartlineAnchor>> _keys = [];

  /// Keys.
  List<List<SmartlineAnchor>> get anchors => _keys;

  /// Add card.
  void addCard(SmartlineAnchor key) {
    if (_cardOrdinal == CardOrdinal.first) {
      _cardOrdinal = CardOrdinal.second;
      _keys.add([key]);
    } else if (_keys.last.contains(key)) {
      return;
    } else if (_cardOrdinal == CardOrdinal.second) {
      _cardOrdinal = CardOrdinal.first;
      _keys.last.add(key);
    }
    notifyListeners();
  }

  @override
  Map<String, dynamic> serialize() => {
        'first': _keys.map((e) => e.first.key.value).toList(),
        'second': _keys.map((e) => e.last.key.value).toList(),
      };

  @override
  Unit deserialize(covariant Map<String, dynamic> data) => effect(() {
        _keys
          ..clear()
          ..addAll(
            Map.fromIterables(
              data['first'] as List<dynamic>,
              data['second'] as List<dynamic>,
            ).entries.map(
                  (e) => [
                    SmartlineAnchor(
                      key: GlobalObjectKey(e.key),
                      type: SmartlineType.field,
                    ),
                    SmartlineAnchor(
                      key: GlobalObjectKey(e.value),
                      type: SmartlineType.field,
                    ),
                  ],
                ),
          );
        notifyListeners();
      });
}
