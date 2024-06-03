part of 'editor_controller.dart';

class _InvalidCellId {
  const _InvalidCellId._();
}

const kInvalidCellId = _InvalidCellId._();

@freezed
class DependencyEvent<Event extends EventBase, State extends StateBase>
    extends EventBase with _$DependencyEvent<Event, State> {
  const DependencyEvent._();

  const factory DependencyEvent({
    required State previous,
    required State current,
    required Event event,
  }) = _DependencyEvent<Event, State>;
}

class CellController extends SyncEventBus<CellState> {
  CellController._({
    required this.id,
    required this.model,
    required super.state,
    required this.editor,
    required this.extraPlugins,
    CellController? parent,
  }) : _parent = parent {
    _updatePlugins();
    model.addListener(_onModelUpdated);
  }

  final dynamic id;

  final CellModel model;

  final List<CellPlugin> extraPlugins;

  CellController? _parent;

  CellController? get parent => _parent;

  @override
  Iterable<CellPlugin> get plugins => super.plugins.cast();

  @protected
  @override
  set plugins(Iterable<Plugin<CellState>> plugins) {
    super.plugins = plugins;
  }

  final EditorController editor;

  final Map<dynamic, CellController> _children = {};

  final Map<dynamic, CellController> _dependingCells = {};

  final Map<dynamic, CellController> _dependedCells = {};

  Map<dynamic, CellController> get children => UnmodifiableMapView(_children);

  CellController? child(dynamic id) => _children[id];

  void _onModelUpdated() {
    _updatePlugins();
  }

  void _updatePlugins() {
    final pluginIds = <Object?>{};
    final plugins = <CellPlugin>[];

    for (var plugin in [...model.plugins, ...extraPlugins].reversed) {
      if (plugin.id != null && pluginIds.contains(plugin.id)) {
        continue;
      }

      pluginIds.add(plugin.id);
      plugins.add(plugin);
    }

    super.plugins = plugins.reversed.toList();
  }

  void add(CellController cell) {
    _children[cell.id] = cell;
    cell._parent = this;
    for (var plugin in plugins) {
      plugin.onChildAdded(this, cell);
    }
  }

  CellController? remove(dynamic id) {
    final cell = _children.remove(id);
    if (cell != null) {
      cell._parent = null;
      for (var plugin in plugins) {
        plugin.onChildRemoved(this, cell);
      }
    }

    return cell;
  }

  void visitAncestors(bool Function(CellController) vistor) {
    var parent = this.parent;
    while (parent != null) {
      if (!vistor(parent)) {
        return;
      }

      parent = parent.parent;
    }
  }

  bool hasAncestor(dynamic id) {
    var result = false;
    visitAncestors((cell) {
      if (cell.id == id) {
        result = true;
        return false;
      }

      return true;
    });

    return result;
  }

  void visitDescendants(bool Function(CellController) vistor) {
    var children = this.children.values;
    while (children.isNotEmpty) {
      for (var child in children) {
        if (!vistor(child)) {
          return;
        }
      }

      final newChildren = <CellController>[];
      for (var child in children) {
        newChildren.addAll(child.children.values);
      }
    }
  }

  CellController? findDescendant(dynamic id) {
    final cell = editor.cells[id];
    if (cell == null) {
      return null;
    }

    return cell.hasAncestor(this.id) ? cell : null;
  }

  bool hasDescendant(dynamic id) {
    final cell = editor.cells[id];
    if (cell == null) {
      return false;
    }

    return cell.hasAncestor(this.id);
  }

  void _addDependingCell(CellController cell) {
    _dependingCells[cell.id] = cell;
  }

  void _removeDependingCell(CellController cell) {
    _dependingCells.remove(cell.id);
  }

  void _addDependedCell(CellController cell) {
    _dependedCells[cell.id] = cell;
  }

  void _removeDependedCell(CellController cell) {
    _dependedCells.remove(cell.id);
  }

  void initializePluginState<T>(T Function(T?) creator) {
    update(state.update(creator(state.maybe<T>())));
  }

  Disposable depend<Event extends EventBase>(
    EventHandler<DependencyEvent<Event, CellState>, CellState> handler, {
    HandlerPriority priority = HandlerPriority.medium,
  }) {
    return on<DependencyEvent<Event, CellState>>(handler);
  }

  @override
  void onAfterInvoke<Event extends EventBase>(Event event, CellState previous) {
    if (event is DependencyEvent) {
      return;
    }

    super.onAfterInvoke(event, previous);

    for (var dependedCell in _dependedCells.values) {
      dependedCell.invoke(
        DependencyEvent(
          previous: previous,
          current: state,
          event: event,
        ),
      );
    }
  }

  @override
  String toString() {
    return '<Cell $id>';
  }

  @override
  Future<void> close() {
    model.removeListener(_onModelUpdated);
    return super.close();
  }
}

abstract class CellPlugin
    extends AutoDisposePluginBase<CellState, CellController> {
  const CellPlugin();

  Object? get id => null;

  Widget build(
    BuildContext context,
    CellController controller,
    Widget child,
  ) =>
      child;

  void onChildAdded(CellController controller, CellController child) {}

  void onChildRemoved(CellController controller, CellController child) {}
}
