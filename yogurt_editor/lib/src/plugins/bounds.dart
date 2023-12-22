part of 'plugins.dart';

typedef Bounds = Rect;

@freezed
class BoundsEvent with _$BoundsEvent {
  const BoundsEvent._();

  const factory BoundsEvent.update({
    required Bounds bounds,
  }) = UpdateBoundsEvent;
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
  }
}
