import 'dart:developer';

import 'package:database_diagrams/collections/card_ordinal.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// SmartLineController.
class SmartlineController extends ChangeNotifier {
  /// Provider.
  static final provider = ChangeNotifierProvider<SmartlineController>(
    (ref) => SmartlineController(),
  );

  CardOrdinal _cardOrdinal = CardOrdinal.first;

  final List<List<GlobalObjectKey>> _keys = [];

  /// Keys.
  List<List<GlobalObjectKey>> get keys => _keys;

  /// Add card.
  void addCard(GlobalObjectKey key) {
    if (_cardOrdinal == CardOrdinal.first) {
      _cardOrdinal = CardOrdinal.second;
      _keys.add([key]);
    } else if (_keys.last.contains(key)) {
      log('Cannot have duplicates in pairs.');
      return;
    } else if (_cardOrdinal == CardOrdinal.second) {
      _cardOrdinal = CardOrdinal.first;
      _keys.last.add(key);
    }
    notifyListeners();
    log(_keys.toString());
  }
}
