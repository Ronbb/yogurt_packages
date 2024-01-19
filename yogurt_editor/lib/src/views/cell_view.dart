import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:yogurt_editor/src/editor_controller.dart';
import 'package:yogurt_editor/src/plugins/plugins.dart';

class CellView extends StatefulWidget {
  const CellView({
    super.key,
    required this.controller,
  });

  final CellController controller;

  @override
  State<CellView> createState() => _CellViewState();
}

class _CellViewState extends State<CellView> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ValueListenableBuilder(
      valueListenable: controller.children,
      builder: (context, value, child) {
        return CellContainer(
          controller: controller,
          children: [
            if (child != null) child,
            for (final child in value.values)
              CellView(
                controller: child,
              ),
          ],
        );
      },
      child: StreamBuilder(
        stream: controller.stream,
        initialData: controller.state,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final state = snapshot.data!;
          return state.model.build(context, state);
        },
      ),
    );
  }
}

class CellContainer extends MultiChildRenderObjectWidget {
  const CellContainer({
    super.key,
    super.children,
    required this.controller,
  });

  final CellController controller;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCellContainer()..controller = controller;
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderCellContainer renderObject) {
    renderObject.controller = controller;
  }
}

class CellParentData extends ContainerBoxParentData<RenderBox> {}

class RenderCellContainer extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin {
  CellController? _controller;
  StreamSubscription? _subscription;
  CellController get controller => _controller!;
  set controller(CellController controller) {
    if (_controller != controller) {
      _controller = controller;
      _subscription?.cancel();
      _subscription = controller.stream.listen(_onCellStateChanged);
      markNeedsLayout();
    }
  }

  Bounds? _lastBounds;

  void _onCellStateChanged(CellState state) {
    if (!attached) {
      return;
    }

    final bounds = state.maybePlugin<Bounds>();
    if (_lastBounds != bounds) {
      _lastBounds = bounds;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! CellParentData) {
      child.parentData = CellParentData();
    }
  }

  CellParentData? get cellParentData =>
      parentData is CellParentData ? parentData as CellParentData : null;

  @override
  void performLayout() {
    cellParentData?.offset = controller.position ?? Offset.zero;

    if (controller.size != null) {
      size = controller.size!;
      visitChildren((child) {
        child.layout(
          child is RenderCellContainer
              ? const BoxConstraints()
              : BoxConstraints.tight(size),
        );
      });
    } else {
      var size = controller.size ?? Size.zero;

      visitChildren((child) {
        child.layout(
          child is RenderCellContainer ? const BoxConstraints() : constraints,
          parentUsesSize: true,
        );

        final childSize = (child as RenderBox).size;

        size = Size(
          max(size.width, childSize.width),
          max(size.height, childSize.height),
        );
      });

      this.size = size;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
