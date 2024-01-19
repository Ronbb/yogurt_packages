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

class BoundsPlugin extends CellPluginBase {
  const BoundsPlugin();

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

extension EditorHitTest on EditorController {
  @useResult
  CellController? hitTest(Offset position) {
    return root.hitTest(position);
  }
}

extension CellHitTest on CellController {
  @useResult
  CellController? hitTest(Offset position) {
    if (_maybeBounds?.contains(position) ?? true) {
      for (var child in children.value.values) {
        final result = child.hitTest(position - (maybePosition ?? Offset.zero));
        if (result != null) {
          return result;
        }
      }

      if (_maybeBounds != null) {
        return this;
      }
    }

    return null;
  }
}

extension CellMaybeBounds on CellController {
  Bounds? get editorBounds {
    if (!state.has<Bounds>()) {
      return null;
    }

    var bounds = state.plugin<Bounds>();
    visitAncestors((cell) {
      if (!cell.state.has<Bounds>()) {
        return true;
      }

      bounds = bounds.shift(cell.state.plugin<Bounds>().topLeft);

      return true;
    });

    return bounds;
  }

  Bounds? get _maybeBounds {
    if (!state.has<Bounds>()) {
      return null;
    }

    return state.plugin<Bounds>();
  }

  Offset? get maybeCenter => _maybeBounds?.center;

  Offset? get maybePosition => _maybeBounds?.position;

  Size? get maybeSize => _maybeBounds?.size;
}
