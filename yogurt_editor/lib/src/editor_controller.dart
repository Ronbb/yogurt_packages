import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

import 'cell_model.dart';

part 'cell_controller.dart';
part 'editor_controller.freezed.dart';

class EditorController extends AsyncEventBus<EditorState> {
  EditorController({
    dynamic rootId,
    CellState rootState = const CellState(),
    required CellModel rootModel,
    super.state = const EditorState(),
    List<EditorPlugin> plugins = const [],
  }) : super(plugins: plugins) {
    root = _create(rootId, rootState, rootModel);
    _cells[root.id] = root;
  }

  late final CellController root;

  final Map<dynamic, CellController> _cells = {};

  Map<dynamic, CellController> get cells => UnmodifiableMapView(_cells);

  @override
  Iterable<EditorPlugin> get plugins => super.plugins.cast();

  CellController _create(
    dynamic id,
    CellState state,
    CellModel model, {
    List<CellPlugin> extraPlugins = const [],
  }) {
    return CellController._(
      id: id,
      editor: this,
      state: state,
      model: model,
      extraPlugins: extraPlugins,
    );
  }

  CellController create({
    required dynamic id,
    required CellModel model,
    CellState state = const CellState(),
    CellController? parent,
    List<CellPlugin> extraPlugins = const [],
  }) {
    if (_cells.containsKey(id)) {
      throw Exception('cell with id $id is existed');
    }

    final cell = _create(
      id,
      state,
      model,
      extraPlugins: extraPlugins,
    );

    _cells[id] = cell;

    (parent ?? root).add(cell);

    return cell;
  }

  CellController? remove(dynamic id) {
    final cell = _cells.remove(id);

    cell?.parent?.remove(id);

    return cell;
  }

  void reattach(CellController parent, CellController child) {
    if (child.parent == parent) {
      return;
    }
    child.parent?.remove(child.id);
    parent.add(child);
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

abstract class EditorPlugin
    extends AutoDisposePluginBase<EditorState, EditorController> {
  const EditorPlugin();

  CellPlugin? get cell => null;
}

typedef EditorState = DynamicState;

typedef CellState = DynamicState;

@freezed
class DynamicState extends StateBase with _$DynamicState {
  const DynamicState._();

  const factory DynamicState([@Default({}) Map<Type, dynamic> all]) =
      _DynamicState;

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
