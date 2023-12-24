import 'dart:collection';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

import 'cell_model.dart';
import 'notifier.dart';

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

abstract class EditorPluginBase extends PluginBase<EditorController> {
  const EditorPluginBase();

  CellPluginBase? get cell => null;
}

@freezed
class StateWithPlugins extends StateBase with _$StateWithPlugins {
  const StateWithPlugins._();

  const factory StateWithPlugins.editor({
    @Default({}) Map<Type, dynamic> plugins,
  }) = EditorState;
  const factory StateWithPlugins.cell({
    required dynamic id,
    required CellModelBase model,
    @Default({}) Map<Type, dynamic> plugins,
  }) = CellState;

  @useResult
  T plugin<T>() {
    return plugins[T]!;
  }

  @useResult
  R rebuildWithPlugin<T, R>(T Function(T plugin) rebuilder) {
    return copyWithPlugin(rebuilder(plugin()));
  }

  @useResult
  R copyWithPlugin<T, R>(T plugin) {
    return copyWith(plugins: Map.of(plugins)..[T] = plugin) as R;
  }
}
