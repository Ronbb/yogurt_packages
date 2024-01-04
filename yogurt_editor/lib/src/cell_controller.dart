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

class CellController extends EventBus<CellState> {
  CellController._({
    required super.state,
    super.plugins,
    CellController? parent,
    required this.editor,
  }) : _parent = parent;

  CellController? _parent;

  CellController? get parent => _parent;

  final EditorController editor;

  final Map<dynamic, CellController> _children = {};

  final Map<dynamic, CellController> _dependingCells = {};

  final Map<dynamic, CellController> _dependedCells = {};

  late final children = UnmodifiedValueNotifier(UnmodifiableMapView(_children));

  CellController? child(dynamic id) => _children[id];

  void _add(CellController cell) {
    _children[cell.state.id] = cell;
    cell._parent = this;
    children.notify();
  }

  CellController? _remove(dynamic id) {
    final cell = _children.remove(id);
    cell?._parent = null;
    children.notify();
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
      if (cell.state.id == id) {
        result = true;
        return false;
      }

      return true;
    });

    return result;
  }

  void visitDescendants(bool Function(CellController) vistor) {
    var children = this.children.value.values;
    while (children.isNotEmpty) {
      for (var child in children) {
        if (!vistor(child)) {
          return;
        }
      }

      final newChildren = <CellController>[];
      for (var child in children) {
        newChildren.addAll(child.children.value.values);
      }
    }
  }

  CellController? findDescendant(dynamic id) {
    final cell = editor.cells[id];
    if (cell == null) {
      return null;
    }

    return cell.hasAncestor(id) ? cell : null;
  }

  bool hasDescendant(dynamic id) {
    final cell = editor.cells[id];
    if (cell == null) {
      return false;
    }

    return cell.hasAncestor(id);
  }

  void _addDependingCell(CellController cell) {
    _dependingCells[cell.state.id] = cell;
  }

  void _removeDependingCell(CellController cell) {
    _dependingCells.remove(cell.state.id);
  }

  void _addDependedCell(CellController cell) {
    _dependedCells[cell.state.id] = cell;
  }

  void _removeDependedCell(CellController cell) {
    _dependedCells.remove(cell.state.id);
  }

  void initializePluginState<T>(T Function(T?) creator) {
    update(state.copyWithPlugin(creator(state.plugins[T])));
  }

  void depend<Event extends EventBase>(
    EventHandler<DependencyEvent<Event, CellState>, CellState> handler, {
    HandlerPriority priority = HandlerPriority.medium,
  }) {
    on<DependencyEvent<Event, CellState>>(handler);
  }

  @override
  FutureOr<void> onAfterInvoke(EventBase event, CellState previous) async {
    if (event is DependencyEvent) {
      return;
    }

    await super.onAfterInvoke(event, previous);

    for (var dependedCell in _dependedCells.values) {
      await dependedCell.invoke(
        DependencyEvent(
          previous: previous,
          current: state,
          event: event,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    children.dispose();
    return super.close();
  }
}

typedef CellPluginBase = PluginBase<CellController>;
