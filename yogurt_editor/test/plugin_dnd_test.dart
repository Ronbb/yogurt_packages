import 'package:flutter_test/flutter_test.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

import 'test_utils.dart';

void main() {
  group('dnd', () {
    final editor = EditorController(
      state: const EditorState(),
      root: TestCellModel.create(),
      plugins: const [DragPlugin(), BoundsPlugin()],
    );

    test('initial', () async {
      final cell = editor.create(TestCellModel.create());
      expect(cell.state.plugin<Drag>(), isNotNull);
    });

    test('drag start', () async {
      final cell = editor.create(TestCellModel.create());

      final result = await cell.invoke(const DragStartEvent());

      expect(result, isA<InvokeDone>());
      expect(cell.state.plugin<Drag>(), isA<Dragging>());
      expect(
        cell.state.plugin<Drag>(),
        Dragging(
          initialPosition: Offset.zero,
          initialParentId: cell.parent?.state.id,
        ),
      );
    });

    test('drag update', () async {
      final cell = editor.create(TestCellModel.create());

      await cell.invoke(const DragStartEvent());
      final result = await cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      expect(result, isA<InvokeDone>());
      expect(cell.state.plugin<Drag>(), isA<Dragging>());
      expect(cell.state.plugin<Bounds>().position, const Offset(100, 100));
      await cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      expect(cell.state.plugin<Bounds>().position, const Offset(200, 200));
    });

    test('drag complete', () async {
      final cell = editor.create(TestCellModel.create());

      await cell.invoke(const DragStartEvent());
      await cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      final result = await cell.invoke(const DragCompleteEvent());
      expect(result, isA<InvokeDone>());
      expect(cell.state.plugin<Drag>(), isA<DragReady>());
      expect(cell.state.plugin<Bounds>().position, const Offset(100, 100));
      // not working
      await cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      expect(cell.state.plugin<Bounds>().position, const Offset(100, 100));
    });

    test('drag cancel', () async {
      final cell = editor.create(TestCellModel.create());

      await cell.invoke(const DragStartEvent());
      await cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      final result = await cell.invoke(const DragCancelEvent());
      expect(result, isA<InvokeDone>());
      expect(cell.state.plugin<Drag>(), isA<DragReady>());
      expect(cell.state.plugin<Bounds>().position, Offset.zero);
      // not working
      await cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      expect(cell.state.plugin<Bounds>().position, Offset.zero);
    });

    test('drop', () async {
      final editor = EditorController(
        state: const EditorState(),
        root: TestCellModel.create({
          Bounds: const Bounds.fromLTWH(0, 0, 1000, 1000),
        }),
        plugins: const [DragPlugin(), BoundsPlugin()],
      );

      final container = editor.create(TestCellModel.create({
        Bounds: const Bounds.fromLTWH(0, 0, 400, 400),
      }));

      final cell = editor.create(
        TestCellModel.create({
          Bounds: const Bounds.fromLTWH(100, 100, 100, 100),
        }),
        parent: container,
      );

      await cell.invoke(const DragStartEvent());
      await cell.invoke(const DragUpdateEvent(
        delta: Offset(500, 500),
      ));
      await cell.invoke(const DragCompleteEvent());

      expect(cell.parent, editor.root);

      await cell.invoke(const DragStartEvent());
      await cell.invoke(const DragUpdateEvent(
        delta: Offset(-500, -500),
      ));
      await cell.invoke(const DragCompleteEvent());

      expect(cell.parent, container);
    });
  });
}
