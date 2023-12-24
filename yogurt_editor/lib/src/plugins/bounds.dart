part of 'plugins.dart';

typedef Bounds = Rect;

@freezed
class BoundsEvent extends EventBase with _$BoundsEvent {
  const BoundsEvent._();

  const factory BoundsEvent.resize({
    required Offset delta,
  }) = ResizeEvent;

  const factory BoundsEvent.move({
    required Offset delta,
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

    controller.on<MoveEvent>((event, update) {
      update(controller.state.rebuildWithPlugin((Bounds bounds) {
        return bounds.shift(event.delta);
      }));
    });

    controller.on<ResizeEvent>((event, update) {
      update(controller.state.rebuildWithPlugin((Bounds bounds) {
        return bounds.topLeft & (bounds.size + event.delta);
      }));
    });
  }
}
