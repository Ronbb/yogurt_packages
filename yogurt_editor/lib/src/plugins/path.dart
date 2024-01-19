part of 'plugins.dart';

@freezed
class PathEvent extends EventBase with _$PathEvent {
  const PathEvent._();

  const factory PathEvent.rebuild() = PathRebuildEvent;
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

  // bool _isAvailableTerminal(CellController controller, dynamic id) {
  //   return controller.parent?.hasDescendant(id) ?? false;
  // }

  void _createDependency(CellController controller, dynamic id) {
    final cell = controller.editor.cells[id];
    if (cell == null) {
      return;
    }
    controller.editor.createDependency(cell, controller);
    cell.visitAncestors((cell) {
      if (cell == controller.parent) {
        return false;
      }

      controller.editor.createDependency(cell, controller);
      return true;
    });
  }

  Future<CellState> _rebuild(CellController controller) async {
    final edgePath = controller.state.plugin<EdgePath>();

    final path = Path();

    final parent = controller.parent;
    final source = parent?.findDescendant(edgePath.sourceId);
    final target = parent?.findDescendant(edgePath.targetId);
    final points = <Offset?>[];

    Offset? relativePosition(CellController? cell) {
      if (cell == null) {
        return null;
      }

      var position = cell.center ?? Offset.zero;

      cell.visitAncestors((ancestor) {
        if (ancestor == controller.parent) {
          return false;
        }

        final ancestorPosition = ancestor.position;
        if (ancestorPosition != null) {
          position += ancestorPosition;
        }

        return true;
      });

      return position;
    }

    points.add(relativePosition(source));
    points.addAll(edgePath.waypoints);
    points.add(relativePosition(target));

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

    return controller.state.rebuildWithPlugin((EdgePath edgePath) {
      return edgePath.copyWith(
        path: path,
      );
    });
  }

  @override
  void onCreate(CellController controller) {
    controller.initializePluginState<EdgePath>(
      (edgePath) {
        if (edgePath == null) {
          return const EdgePath();
        }

        return edgePath;
      },
    );

    final initialEdgePath = controller.state.plugin<EdgePath>();
    _createDependency(controller, initialEdgePath.sourceId);
    _createDependency(controller, initialEdgePath.targetId);

    controller.on<PathRebuildEvent>((event, update) async {
      update(await _rebuild(controller));
    });

    controller.depend<MoveEvent>((event, update) async {
      update(await _rebuild(controller));
    });

    controller.depend<ResizeEvent>((event, update) async {
      update(await _rebuild(controller));
    });

    controller.depend<MoveRelativeEvent>((event, update) async {
      update(await _rebuild(controller));
    });

    controller.depend<ResizeRelativeEvent>((event, update) async {
      update(await _rebuild(controller));
    });
  }
}
