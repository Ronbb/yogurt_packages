part of 'plugins.dart';

@freezed
class Drag with _$Drag {
  const Drag._();

  const factory Drag.disabled() = DragDisabled;

  const factory Drag.ready() = DragReady;

  const factory Drag.dragging({
    required Offset initialPosition,
    required dynamic initialParentId,
  }) = Dragging;
}

@freezed
class Drop with _$Drop {
  const Drop._();

  const factory Drop.disabled() = DropDisabled;

  const factory Drop.ready({
    @Default(AllAllowedDropTest()) DropTest test,
  }) = DropReady;
}

abstract class DropTest {
  const DropTest();

  bool call(CellController target, CellController dragging);
}

class AllAllowedDropTest extends DropTest {
  const AllAllowedDropTest();

  @override
  bool call(CellController target, CellController dragging) => true;
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

class DropPlugin extends CellPlugin {
  const DropPlugin();

  @override
  Iterable<Disposable> onCreate(CellController controller) sync* {
    controller.initializePluginState<Drop>(
      (drop) => drop ?? const Drop.ready(),
    );
  }

  @override
  Widget build(BuildContext context, CellController controller, Widget child) {
    return child;
  }
}

class DragPlugin extends CellPlugin {
  const DragPlugin();

  @override
  Iterable<Disposable> onCreate(CellController controller) sync* {
    controller.initializePluginState<Drag>(
      (drag) => drag ?? const Drag.ready(),
    );

    yield controller.on<DragStartEvent>((event, update) {
      update(controller.state.rebuild((Drag drag) {
        return drag.maybeWhen(
          orElse: () => drag,
          ready: () => Drag.dragging(
            initialPosition: controller.state<Bounds>().position,
            initialParentId: controller.parent?.id,
          ),
        );
      }));
    });

    yield controller.on<DragUpdateEvent>((event, update) async {
      final drag = controller.state<Drag>();
      if (drag is Dragging) {
        final result = controller.invoke(MoveRelativeEvent(
          delta: event.delta,
        ));

        if (result is InvokeDone) {
          final hitTestResult = controller.editor.hitTest(
                result.state<Bounds>().position,
              ) ??
              controller.editor.root;

          var newParent = hitTestResult == controller
              ? hitTestResult.parent
              : hitTestResult;
          while (newParent != null) {
            if (!newParent.state.has<Drop>()) {
              newParent = newParent.parent;
            } else {
              break;
            }
          }
          if (newParent == null) {
            return;
          }

          final drop = newParent.state<Drop>();
          if (drop is! DropReady || !drop.test(newParent, controller)) {
            return;
          }

          controller.editor.reattach(newParent, controller);
        }
      }
    });

    yield controller.on<DragCompleteEvent>((event, update) {
      update(controller.state.rebuild((Drag drag) {
        return drag.maybeMap(
          orElse: () => drag,
          dragging: (_) => const Drag.ready(),
        );
      }));
    });

    yield controller.on<DragCancelEvent>((event, update) async {
      final drag = controller.state<Drag>();
      if (drag is Dragging) {
        controller.invoke(MoveEvent(
          position: drag.initialPosition,
        ));
        update(controller.state.update(const Drag.ready()));
        controller.editor.reattach(
          controller.editor.cells[drag.initialParentId]!,
          controller,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context, CellController controller, Widget child) {
    return GestureDetector(
      onPanStart: (details) {
        controller.invoke(const DragStartEvent());
      },
      onPanUpdate: (details) {
        controller.invoke(DragUpdateEvent(delta: details.delta));
      },
      onPanEnd: (details) {
        // check drop result and invoke canceled event.
        controller.invoke(const DragCompleteEvent());
      },
      child: child,
    );
  }
}
