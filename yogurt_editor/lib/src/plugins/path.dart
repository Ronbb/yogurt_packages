part of 'plugins.dart';

@freezed
class PathEvent extends EventBase with _$PathEvent {
  const PathEvent._();

  const factory PathEvent.rebuild({
    required Offset delta,
  }) = PathRebuildEvent;
}

@freezed
class EdgePath with _$EdgePath {
  const EdgePath._();

  const factory EdgePath({
    dynamic sourceId,
    dynamic targetId,
    @Default([]) List<Offset> waypoints,
    Path? path,
  }) = _EdgePath;
}

class PathPlugin extends EditorPluginBase {
  const PathPlugin();

  @override
  void onCreate(EditorController controller) {}
}

class CellPathPlugin extends CellPluginBase {
  const CellPathPlugin();

  @override
  void onCreate(CellController controller) {
    controller.initializePluginState<EdgePath>(
      (edgePath) => edgePath ?? const EdgePath(),
    );

    final initialEdgePath = controller.state.plugin<EdgePath>();
    final source = controller.editor.cells[initialEdgePath.sourceId];
    final target = controller.editor.cells[initialEdgePath.targetId];
    if (source != null) {
      controller.addDependency(source);
    }
    if (target != null) {
      controller.addDependency(target);
    }

    controller.on<PathRebuildEvent>((event, update) async {
      final edgePath = controller.state.plugin<EdgePath>();

      final path = Path();

      final parent = controller.parent;
      final source = parent?.findDescendant(edgePath.sourceId);
      final target = parent?.findDescendant(edgePath.targetId);
      final points = <Offset?>[];

      points.add(source?.center);
      points.addAll(edgePath.waypoints);
      points.add(target?.center);

      final availablePoints = points.whereType<Offset>();
      if (availablePoints.isNotEmpty) {
        final first = availablePoints.first;
        path.moveTo(first.dx, first.dy);

        for (var point in availablePoints.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
      }

      final bounds = path.getBounds();
      await controller.invoke(MoveEvent(
        position: bounds.position,
      ));
      await controller.invoke(ResizeEvent(
        size: bounds.size,
      ));

      update(controller.state.rebuildWithPlugin((EdgePath edgePath) {
        return edgePath.copyWith(
          path: path,
        );
      }));
    });
  }
}
