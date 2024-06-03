import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('bounds', () {
    final editor = EditorController(
      state: const EditorState(),
      root: TestCellModel.create(),
    );

    test('initial', () async {
      final cell = editor.createTest(
        plugins: const [BoundsPlugin()],
      );
      expect(cell.state<Bounds>(), isNotNull);
    });

    test('hit test', () async {
      final editor = EditorController(
        state: const EditorState(),
        root: TestCellModel.create(),
      );

      final cell1 = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 0,
            top: 0,
            width: 200,
            height: 200,
          ),
        },
        plugins: const [BoundsPlugin()],
      );

      final cell2 = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 50,
            top: 50,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [BoundsPlugin()],
        parent: cell1,
      );

      final result1 = editor.hitTest(const Offset(100, 100));
      expect(result1, cell2);

      final result2 = editor.hitTest(const Offset(25, 25));
      expect(result2, cell1);

      final result3 = editor.hitTest(const Offset(300, 300));
      expect(result3, null);
    });

    test('move relatively', () async {
      final cell = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 100,
            top: 100,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [BoundsPlugin()],
      );

      final result = cell.invoke(
        const MoveRelativeEvent(
          delta: Offset(50, 50),
        ),
      );
      expect(result, isA<InvokeDone>());
      expect(cell.state<Bounds>().position, const Offset(150, 150));
    });

    test('move', () async {
      final cell = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 100,
            top: 100,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [BoundsPlugin()],
      );

      final result = cell.invoke(
        const MoveEvent(
          position: Offset(50, 50),
        ),
      );
      expect(result, isA<InvokeDone>());
      expect(cell.state<Bounds>().position, const Offset(50, 50));
    });

    test('resize relatively', () async {
      final cell = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 100,
            top: 100,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [BoundsPlugin()],
      );

      final result = cell.invoke(
        const ResizeRelativeEvent(
          delta: Offset(50, 50),
        ),
      );
      expect(result, isA<InvokeDone>());
      expect(cell.state<Bounds>().size, const Size(150, 150));
    });
  });
}
