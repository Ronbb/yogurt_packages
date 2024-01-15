import 'dart:async';
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
    _cells[root.id] = this.root;
  }

  late final CellController root;

  final Map<dynamic, CellController> _cells = {};

  Map<dynamic, CellController> get cells => UnmodifiableMapView(_cells);

  @override
  List<EditorPluginBase> get plugins => super.plugins.cast();

  late final List<CellPluginBase> _cellPlugins;

  CellController _create(
    CellState state, {
    List<CellPluginBase> extraCellPlugins = const [],
  }) {
    return CellController._(
      editor: this,
      state: state,
      plugins: [..._cellPlugins, ...extraCellPlugins],
    );
  }

  CellController create(
    CellState state, {
    CellController? parent,
    List<CellPluginBase> extraCellPlugins = const [],
  }) {
    if (_cells.containsKey(state.id)) {
      throw Exception('cell with id ${state.id} is existed');
    }

    final cell = _create(
      state,
      extraCellPlugins: extraCellPlugins,
    );

    _cells[state.id] = cell;

    (parent ?? root)._add(cell);

    return cell;
  }

  CellController? remove(dynamic id) {
    final cell = _cells.remove(id);

    cell?.parent?._remove(id);

    return cell;
  }

  void reattach(CellController parent, CellController child) {
    if (child.parent == parent) {
      return;
    }
    child.parent?._remove(child.state.id);
    parent._add(child);
  }

  void createDependency(CellController depended, CellController depending) {
    depended._addDependedCell(depending);
    depending._addDependingCell(depended);
  }

  void removeDependency(CellController depended, CellController depending) {
    depended._removeDependedCell(depending);
    depending._removeDependingCell(depended);
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
  bool has<T>() {
    return plugins.containsKey(T);
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
