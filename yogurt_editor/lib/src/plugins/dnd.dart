part of 'plugins.dart';

@freezed
class Drag with _$Drag {
  const Drag._();

  const factory Drag.disabled() = DragDisabled;

  const factory Drag.ready() = DragReady;

  const factory Drag.dragging({
    required Offset initialPosition,
  }) = Dragging;
}

@freezed
class DragEvent extends EventBase with _$DragEvent {
  const DragEvent._();

  const factory DragEvent.start() = DragStartEvent;

  const factory DragEvent.update({
    required Offset delta,
  }) = DragUpdateEvent;

  const factory DragEvent.complete() = DragCompleteEvent;

  const factory DragEvent.cancel() = DragCancelEvent;
}

class DragPlugin extends EditorPluginBase {
  const DragPlugin();

  @override
  final CellDragPlugin cell = const CellDragPlugin();

  @override
  void onCreate(EditorController controller) {}
}

class CellDragPlugin extends CellPluginBase {
  const CellDragPlugin();

  @override
  void onCreate(CellController controller) {
    controller.initializePluginState<Drag>(
      (drag) => drag ?? const Drag.ready(),
    );

    controller.on<DragStartEvent>((event, update) {
      update(controller.state.rebuildWithPlugin((Drag drag) {
        return drag.maybeWhen(
          orElse: () => drag,
          ready: () => Drag.dragging(
            initialPosition: controller.state.plugin<Bounds>().position,
          ),
        );
      }));
    });

    controller.on<DragUpdateEvent>((event, update) async {
      final drag = controller.state.plugin<Drag>();
      if (drag is Dragging) {
        await controller.invoke(MoveRelativeEvent(
          delta: event.delta,
        ));
      }
    });

    controller.on<DragCompleteEvent>((event, update) {
      update(controller.state.rebuildWithPlugin((Drag drag) {
        return drag.maybeWhen(
          orElse: () => drag,
          dragging: (_) => const Drag.ready(),
        );
      }));
    });

    controller.on<DragCancelEvent>((event, update) async {
      final drag = controller.state.plugin<Drag>();
      if (drag is Dragging) {
        await controller.invoke(MoveEvent(
          position: drag.initialPosition,
        ));
        update(controller.state.copyWithPlugin(const Drag.ready()));
      }
    });
  }
}
