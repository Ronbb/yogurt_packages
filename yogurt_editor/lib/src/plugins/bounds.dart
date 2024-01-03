part of 'plugins.dart';

typedef Bounds = Rect;

extension BoundsPosition on Bounds {
  Offset get position => topLeft;
}

@freezed
class BoundsEvent extends EventBase with _$BoundsEvent {
  const BoundsEvent._();

  const factory BoundsEvent.resizeRelative({
    required Offset delta,
  }) = ResizeRelativeEvent;

  const factory BoundsEvent.resize({
    required Size size,
  }) = ResizeEvent;

  const factory BoundsEvent.moveRelative({
    required Offset delta,
  }) = MoveRelativeEvent;

  const factory BoundsEvent.move({
    required Offset position,
  }) = MoveEvent;
}

class BoundsPlugin extends EditorPluginBase {
  const BoundsPlugin();

  @override
  final CellBoundsPlugin cell = const CellBoundsPlugin();

  @override
  void onCreate(EditorController controller) {}
}

class CellBoundsPlugin extends CellPluginBase {
  const CellBoundsPlugin();

  @override
  void onCreate(CellController controller) {
    controller.initializePluginState<Bounds>((bounds) => bounds ?? Bounds.zero);

    controller.on<MoveRelativeEvent>((event, update) {
      update(controller.state.rebuildWithPlugin((Bounds bounds) {
        return bounds.shift(event.delta);
      }));
    });

    controller.on<ResizeRelativeEvent>((event, update) {
      update(controller.state.rebuildWithPlugin((Bounds bounds) {
        return bounds.position & (bounds.size + event.delta);
      }));
    });

    controller.on<ResizeEvent>((event, update) {
      update(controller.state.rebuildWithPlugin((Bounds bounds) {
        return bounds.position & event.size;
      }));
    });

    controller.on<MoveEvent>((event, update) {
      update(controller.state.rebuildWithPlugin((Bounds bounds) {
        return event.position & bounds.size;
      }));
    });
  }
}

extension BoundsHitTest on EditorController {
  @useResult
  CellController? hitTest(Offset position) {
    CellController? result;
    Iterable<CellController> cells = [root];
    while (true) {
      var hit = false;
      for (var cell in cells) {
        if (!cell.state.has<Bounds>()) {
          continue;
        }

        final bounds = cell.state.plugin<Bounds>();
        if (bounds.contains(position)) {
          hit = true;
          result = cell;
          cells = cell.children.value.values;
          break;
        }
      }

      if (!hit) {
        break;
      }
    }
    return result;
  }
}

extension CellMaybeBounds on CellController {
  Bounds? get editorBounds {
    if (!state.has<Bounds>()) {
      return null;
    }

    var bounds = state.plugin<Bounds>();
    visitAncestors((cell) {
      if (!state.has<Bounds>()) {
        return true;
      }

      bounds = bounds.shift(state.plugin<Bounds>().topLeft);

      return true;
    });

    return bounds;
  }

  Bounds? get _bounds {
    if (!state.has<Bounds>()) {
      return null;
    }

    return state.plugin<Bounds>();
  }

  Offset? get center => _bounds?.center;

  Offset? get position => _bounds?.position;
}
