import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

import 'plugin_state.dart';

part 'cell_controller.freezed.dart';

class CellController extends EventBus<CellState> {
  CellController({
    required super.state,
    super.plugins,
  });
}

@freezed
class CellState extends StateBase with _$CellState {
  const CellState._();

  const factory CellState({
    required Object id,
    @Default(PluginState()) PluginState plugins,
  }) = _CellState;
}
