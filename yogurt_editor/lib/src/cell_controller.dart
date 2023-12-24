part of 'editor_controller.dart';

class CellController extends EventBus<CellState> {
  CellController._({
    required super.state,
    super.plugins,
    CellController? parent,
  }) : _parent = parent;

  CellController? _parent;

  CellController? get parent => _parent;

  final Map<dynamic, CellController> _children = {};

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

  void initializePluginState<T>(T Function(T?) creator) {
    update(state.copyWithPlugin(creator(state.plugins[T])));
  }

  @override
  Future<void> close() {
    children.dispose();
    return super.close();
  }
}

typedef CellPluginBase = PluginBase<CellController>;
