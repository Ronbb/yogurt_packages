import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

import 'cell_model.dart';
import 'notifier.dart';
import 'plugin_state.dart';

part 'cell_controller.dart';
part 'editor_controller.freezed.dart';

class EditorController extends EventBus<EditorState> {
  EditorController({
    required CellState root,
    super.state = const EditorState(),
    List<EditorPluginBase> plugins = const [],
  }) : super(plugins: plugins) {
    _cellPlugins = plugins
        .map((e) => e.cell)
        .whereType<PluginBase<CellController>>()
        .toList();
    this.root = _create(root);
  }

  late final CellController root;

  final Map<dynamic, CellController> _cells = {};

  @override
  List<EditorPluginBase> get plugins => super.plugins.cast();

  late final List<PluginBase<CellController>> _cellPlugins;

  CellController _create(CellState state) {
    return CellController._(
      state: state,
      plugins: _cellPlugins,
    );
  }

  CellController create(CellState state, {CellController? parent}) {
    if (_cells.containsKey(state.id)) {
      throw Exception('cell with id ${state.id} is existed');
    }

    final cell = _create(state);

    _cells[state.id] = cell;

    (parent ?? root)._add(cell);

    return cell;
  }

  CellController? remove(dynamic id) {
    final cell = _cells.remove(id);

    cell?.parent?._remove(id);

    return cell;
  }
}

@freezed
class EditorState extends StateBase with _$EditorState {
  const EditorState._();

  const factory EditorState({
    @Default(PluginState()) PluginState plugins,
  }) = _EditorState;

  T? plugin<T>() {
    return plugins.state<T>();
  }
}

abstract class EditorPluginBase extends PluginBase<EditorController> {
  const EditorPluginBase();

  CellPluginBase? get cell => null;
}
