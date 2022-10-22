import 'package:database_diagrams/main/mode.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Mode controller.
class ModeController extends StateNotifier<Mode> {
  /// Default constructor.
  ModeController() : super(Mode.none);

  /// Provider.
  static final provider = StateNotifierProvider<ModeController, Mode>(
    (ref) => ModeController(),
  );

  /// Toggle smart line mode.
  void toogleSmartLine() {
    state = state == Mode.smartLine ? Mode.none : Mode.smartLine;
  }
}
