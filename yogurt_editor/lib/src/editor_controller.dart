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
    this.root = _create(root);
    _cells[root.id] = this.root;
  }

  late final CellController root;

  final Map<dynamic, CellController> _cells = {};

  Map<dynamic, CellController> get cells => UnmodifiableMapView(_cells);

  @override
  List<EditorPluginBase> get plugins => super.plugins.cast();

  CellController _create(
    CellState state, {
    List<CellPluginBase> extraCellPlugins = const [],
  }) {
    final pluginTypes = <Type>{};
    final plugins = <CellPluginBase>[];

    for (var plugin in [...state.model.plugins, ...extraCellPlugins].reversed) {
      if (pluginTypes.contains(plugin.runtimeType)) {
        continue;
      }

      pluginTypes.add(plugin.runtimeType);
      plugins.add(plugin);
    }

    return CellController._(
      editor: this,
      state: state,
      plugins: plugins.reversed.toList(),
    );
  }

  CellController create(
    CellState state, {
    CellController? parent,
    List<CellPluginBase> extraPlugins = const [],
  }) {
    if (_cells.containsKey(state.id)) {
      throw Exception('cell with id ${state.id} is existed');
    }

    final cell = _create(
      state,
      extraCellPlugins: extraPlugins,
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
class StateWithData extends StateBase with _$StateWithData {
  const StateWithData._();

  const factory StateWithData.editor({
    @Default({}) Map<Type, dynamic> all,
  }) = EditorState;
  const factory StateWithData.cell({
    required dynamic id,
    required CellModelBase model,
    @Default({}) Map<Type, dynamic> all,
  }) = CellState;

  @useResult
  T get<T>() {
    return all[T] as T;
  }

  @useResult
  T? maybe<T>() {
    return all[T] as T?;
  }

  @useResult
  T call<T>() {
    return all[T] as T;
  }

  @useResult
  bool has<T>() {
    return all.containsKey(T);
  }

  @useResult
  R rebuild<T, R>(T Function(T data) rebuilder) {
    return update(rebuilder(get()));
  }

  @useResult
  R update<T, R>(T data) {
    return copyWith(all: Map.of(all)..[T] = data) as R;
  }
}
