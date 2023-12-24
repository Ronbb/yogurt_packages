part of 'plugins.dart';

typedef Bounds = Rect;

extension BoundsPosition on Bounds {
  Offset get position => topLeft;
}

@freezed
class BoundsEvent extends EventBase with _$BoundsEvent {
  const BoundsEvent._();

  const factory BoundsEvent.resize({
    required Offset delta,
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

    controller.on<ResizeEvent>((event, update) {
      update(controller.state.rebuildWithPlugin((Bounds bounds) {
        return bounds.position & (bounds.size + event.delta);
      }));
    });

    controller.on<MoveEvent>((event, update) {
      update(controller.state.rebuildWithPlugin((Bounds bounds) {
        return event.position & bounds.size;
      }));
    });
  }
}
