import 'package:flutter_test/flutter_test.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

import 'test_utils.dart';

void main() {
  group('dnd', () {
    final editor = EditorController(
      state: const EditorState(),
      root: TestCellModel.create(),
    );

    test('initial', () async {
      final cell = editor.createTest(
        plugins: const [DragPlugin()],
      );
      expect(cell.state<Drag>(), isNotNull);
    });

    test('drag start', () async {
      final cell = editor.createTest(
        plugins: const [
          DragPlugin(),
          BoundsPlugin(),
        ],
      );

      final result = cell.invoke(const DragStartEvent());

      expect(result, isA<InvokeDone>());
      expect(cell.state<Drag>(), isA<Dragging>());
      expect(
        cell.state<Drag>(),
        Dragging(
          initialPosition: Offset.zero,
          initialParentId: cell.parent?.state.id,
        ),
      );
    });

    test('drag update', () async {
      final cell = editor.createTest(
        plugins: const [
          DragPlugin(),
          BoundsPlugin(),
        ],
      );

      cell.invoke(const DragStartEvent());
      final result = cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      expect(result, isA<InvokeDone>());
      expect(cell.state<Drag>(), isA<Dragging>());
      expect(cell.state<Bounds>().position, const Offset(100, 100));
      cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      expect(cell.state<Bounds>().position, const Offset(200, 200));
    });

    test('drag complete', () async {
      final cell = editor.createTest(
        plugins: const [
          DragPlugin(),
          BoundsPlugin(),
        ],
      );

      cell.invoke(const DragStartEvent());
      cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      final result = cell.invoke(const DragCompleteEvent());
      expect(result, isA<InvokeDone>());
      expect(cell.state<Drag>(), isA<DragReady>());
      expect(cell.state<Bounds>().position, const Offset(100, 100));
      // not working
      cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      expect(cell.state<Bounds>().position, const Offset(100, 100));
    });

    test('drag cancel', () async {
      final cell = editor.createTest(
        plugins: const [
          DragPlugin(),
          BoundsPlugin(),
        ],
      );

      cell.invoke(const DragStartEvent());
      cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      final result = cell.invoke(const DragCancelEvent());
      expect(result, isA<InvokeDone>());
      expect(cell.state<Drag>(), isA<DragReady>());
      expect(cell.state<Bounds>().position, Offset.zero);
      // not working
      cell.invoke(const DragUpdateEvent(
        delta: Offset(100, 100),
      ));
      expect(cell.state<Bounds>().position, Offset.zero);
    });

    test('drop', () async {
      final editor = EditorController(
        state: const EditorState(),
        root: TestCellModel.create(
          plugins: const [
            DropPlugin(),
          ],
        ),
      );

      final container = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 0,
            top: 0,
            width: 400,
            height: 400,
          ),
        },
        plugins: const [
          DragPlugin(),
          DropPlugin(),
          BoundsPlugin(),
        ],
      );

      final cell = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 100,
            top: 100,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [
          DragPlugin(),
          BoundsPlugin(),
        ],
        parent: container,
      );

      cell.invoke(const DragStartEvent());
      cell.invoke(const DragUpdateEvent(
        delta: Offset(500, 500),
      ));
      cell.invoke(const DragCompleteEvent());

      expect(cell.parent, editor.root);

      cell.invoke(const DragStartEvent());
      cell.invoke(const DragUpdateEvent(
        delta: Offset(-500, -500),
      ));
      cell.invoke(const DragCompleteEvent());

      expect(cell.parent, container);
    });

    test('drop disable', () async {
      final editor = EditorController(
        state: const EditorState(),
        root: TestCellModel.create(
          plugins: const [
            DropPlugin(),
          ],
        ),
      );

      final container = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 0,
            top: 0,
            width: 400,
            height: 400,
          ),
          Drop: const Drop.disabled(),
        },
        plugins: const [
          DropPlugin(),
          BoundsPlugin(),
        ],
      );

      final cell = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 100,
            top: 100,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [
          DragPlugin(),
          BoundsPlugin(),
        ],
        parent: container,
      );

      cell.invoke(const DragStartEvent());
      cell.invoke(const DragUpdateEvent(
        delta: Offset(50, 50),
      ));
      cell.invoke(const DragCompleteEvent());

      expect(cell.parent, container);

      cell.invoke(const DragStartEvent());
      cell.invoke(const DragUpdateEvent(
        delta: Offset(500, 500),
      ));
      cell.invoke(const DragCompleteEvent());

      expect(cell.parent, editor.root);

      cell.invoke(const DragStartEvent());
      cell.invoke(const DragUpdateEvent(
        delta: Offset(-500, -500),
      ));
      cell.invoke(const DragCompleteEvent());

      expect(cell.parent, editor.root);
    });

    test('drop prevent', () async {
      final editor = EditorController(
        state: const EditorState(),
        root: TestCellModel.create(
          plugins: const [
            DropPlugin(),
          ],
        ),
      );

      final container = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 0,
            top: 0,
            width: 400,
            height: 400,
          ),
          Drop: const Drop.ready(test: _AllPreventDropTest()),
        },
        plugins: const [
          DropPlugin(),
          BoundsPlugin(),
        ],
      );

      final cell = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 100,
            top: 100,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [
          DragPlugin(),
          BoundsPlugin(),
        ],
        parent: container,
      );

      cell.invoke(const DragStartEvent());
      cell.invoke(const DragUpdateEvent(
        delta: Offset(50, 50),
      ));
      cell.invoke(const DragCompleteEvent());

      expect(cell.parent, container);

      cell.invoke(const DragStartEvent());
      cell.invoke(const DragUpdateEvent(
        delta: Offset(500, 500),
      ));
      cell.invoke(const DragCompleteEvent());

      expect(cell.parent, editor.root);

      cell.invoke(const DragStartEvent());
      cell.invoke(const DragUpdateEvent(
        delta: Offset(-500, -500),
      ));
      cell.invoke(const DragCompleteEvent());

      expect(cell.parent, editor.root);
    });
  });
}

class _AllPreventDropTest extends DropTest {
  const _AllPreventDropTest();

  @override
  bool call(CellController target, CellController dragging) => false;
}
