part of 'editor_controller.dart';

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

  final Map<dynamic, CellController> _dependencies = {};

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

  void _addDependency(CellController cell) {
    _dependencies[cell.state.id] = cell;
  }

  void _removeDependency(CellController cell) {
    _dependencies.remove(cell.state.id);
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

    for (var dependency in _dependencies.values) {
      await dependency.invoke(
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
