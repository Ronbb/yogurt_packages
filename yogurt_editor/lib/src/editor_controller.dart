import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

import 'plugin_state.dart';

part 'editor_controller.freezed.dart';

class EditorController extends EventBus<EditorState> {
  EditorController({required super.state, super.plugins});
}

@freezed
class EditorState extends StateBase with _$EditorState {
  const EditorState._();

  const factory EditorState({
    required Object id,
    @Default(PluginState()) PluginState plugins,
  }) = _EditorState;
}
