part of 'plugins.dart';

@freezed
class Bounds with _$Bounds {
  const Bounds._();

  const factory Bounds.fixed({
    @Default(0) double left,
    @Default(0) double top,
    @Default(0) double width,
    @Default(0) double height,
  }) = FixedBounds;

  const factory Bounds.intrinsic({
    @Default(0) double left,
    @Default(0) double top,
    @Default(0) double width,
    @Default(0) double height,
    required IntrinsicBoundsDelegate delegate,
  }) = IntrinsicBounds;

  Offset get position => Offset(left, top);

  Size get size => Size(width, height);

  Offset get center => Offset(left + width / 2, top + height / 2);

  bool contains(Offset offset) {
    return offset.dx >= left &&
        offset.dx < left + width &&
        offset.dy >= top &&
        offset.dy < top + height;
  }

  Rect toRect() {
    return Rect.fromLTWH(left, top, width, height);
  }

  bool get isFixed => maybeMap(
        fixed: (value) => true,
        orElse: () => false,
      );

  bool get isIntrinsic => maybeMap(
        intrinsic: (value) => true,
        orElse: () => false,
      );
}

@immutable
abstract class IntrinsicBoundsDelegate {
  const IntrinsicBoundsDelegate();

  Size computeDryLayout(CellController controller);
}

mixin BoundsBuilder on CellPlugin {
  @override
  Widget build(BuildContext context, CellController controller, Widget child) {
    final bounds = controller.state<Bounds>();
    return Positioned(
      left: bounds.left,
      top: bounds.top,
      width: bounds.width,
      height: bounds.height,
      child: child,
    );
  }
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

  const factory BoundsEvent.layout() = LayoutEvent;
}

class IntrinsicBoundsPlugin extends CellPlugin with BoundsBuilder {
  const IntrinsicBoundsPlugin({
    required this.delegate,
  });

  final IntrinsicBoundsDelegate delegate;

  @override
  Iterable<Disposable> onCreate(CellController controller) sync* {
    controller.initializePluginState<Bounds>(
      (bounds) {
        bounds ??= IntrinsicBounds(delegate: delegate);

        final size = bounds.maybeMap(
          orElse: () => null,
          intrinsic: (value) {
            return value.delegate.computeDryLayout(controller);
          },
        );

        if (size == null) {
          throw Exception(
            "cell ${controller.id} do not have an IntrinsicBounds",
          );
        }

        bounds = bounds.copyWith(
          width: size.width,
          height: size.height,
        );

        return bounds;
      },
    );

    yield controller.on<MoveEvent>((event, update) {
      update(controller.state.rebuild((Bounds bounds) {
        return bounds.copyWith(
          left: event.position.dx,
          top: event.position.dy,
        );
      }));
    });

    yield controller.on<MoveRelativeEvent>((event, update) {
      update(controller.state.rebuild((Bounds bounds) {
        return bounds.copyWith(
          left: bounds.left + event.delta.dx,
          top: bounds.top + event.delta.dy,
        );
      }));
    });

    yield controller.on<LayoutEvent>((event, update) {
      update(controller.state.rebuild((Bounds bounds) {
        final size = bounds.maybeMap(
          orElse: () => null,
          intrinsic: (value) {
            return value.delegate.computeDryLayout(controller);
          },
        );

        if (size == null) {
          throw Exception(
            "cell ${controller.id} do not have an IntrinsicBounds",
          );
        }

        return bounds.copyWith(
          width: size.width,
          height: size.height,
        );
      }));
    });
  }
}

class BoundsPlugin extends CellPlugin with BoundsBuilder {
  const BoundsPlugin();

  @override
  Iterable<Disposable> onCreate(CellController controller) sync* {
    controller.initializePluginState<Bounds>(
      (bounds) => bounds ?? const FixedBounds(),
    );

    yield controller.on<MoveEvent>((event, update) {
      update(controller.state.rebuild((Bounds bounds) {
        return bounds.copyWith(
          left: event.position.dx,
          top: event.position.dy,
        );
      }));
    });

    yield controller.on<MoveRelativeEvent>((event, update) {
      update(controller.state.rebuild((Bounds bounds) {
        return bounds.copyWith(
          left: bounds.left + event.delta.dx,
          top: bounds.top + event.delta.dy,
        );
      }));
    });

    yield controller.on<ResizeEvent>((event, update) {
      update(controller.state.rebuild((Bounds bounds) {
        return bounds.copyWith(
          width: event.size.width,
          height: event.size.height,
        );
      }));
    });

    yield controller.on<ResizeRelativeEvent>((event, update) {
      update(controller.state.rebuild((Bounds bounds) {
        return bounds.copyWith(
          width: bounds.width + event.delta.dx,
          height: bounds.height + event.delta.dy,
        );
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
      for (var child in children.values) {
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

    var bounds = state<Bounds>();
    visitAncestors((cell) {
      if (!cell.state.has<Bounds>()) {
        return true;
      }

      final cellBounds = cell.state<Bounds>();

      bounds = bounds.copyWith(
        top: bounds.top + cellBounds.top,
        left: bounds.left + cellBounds.left,
      );

      return true;
    });

    return bounds;
  }

  Bounds? get _maybeBounds {
    if (!state.has<Bounds>()) {
      return null;
    }

    return state<Bounds>();
  }

  Offset? get maybeCenter => _maybeBounds?.center;

  Offset? get maybePosition => _maybeBounds?.position;

  Size? get maybeSize => _maybeBounds?.size;
}
