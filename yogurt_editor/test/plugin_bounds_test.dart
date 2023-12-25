import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

import 'test_utils.dart';

void main() {
  group('bounds', () {
    final editor = EditorController(
      state: const EditorState(),
      root: TestCellModel.create(),
      plugins: const [BoundsPlugin()],
    );

    test('initial', () async {
      final cell = editor.create(TestCellModel.create());
      expect(cell.state.plugin<Bounds>(), isNotNull);
    });

    test('hi test', () async {
      final editor = EditorController(
        state: const EditorState(),
        root: TestCellModel.create({
          Bounds: const Bounds.fromLTWH(0, 0, 1000, 1000),
        }),
        plugins: const [BoundsPlugin()],
      );

      final cell1 = editor.create(TestCellModel.create({
        Bounds: const Bounds.fromLTWH(0, 0, 200, 200),
      }));

      final cell2 = editor.create(
        TestCellModel.create({
          Bounds: const Bounds.fromLTWH(50, 50, 100, 100),
        }),
        parent: cell1,
      );

      final result1 = editor.hitTest(const Offset(100, 100));
      expect(result1, hasLength(3));
      expect(result1[0], editor.root);
      expect(result1[1], cell1);
      expect(result1[2], cell2);

      final result2 = editor.hitTest(const Offset(25, 25));
      expect(result2, hasLength(2));
      expect(result2[0], editor.root);
      expect(result2[1], cell1);

      final result3 = editor.hitTest(const Offset(300, 300));
      expect(result3, hasLength(1));
      expect(result3[0], editor.root);
    });

    test('move relatively', () async {
      final cell = editor.create(TestCellModel.create({
        Bounds: const Bounds.fromLTWH(100, 100, 100, 100),
      }));

      final result = await cell.invoke(
        const MoveRelativeEvent(
          delta: Offset(50, 50),
        ),
      );
      expect(result, isA<InvokeDone>());
      expect(cell.state.plugin<Bounds>().position, const Offset(150, 150));
    });

    test('move', () async {
      final cell = editor.create(TestCellModel.create({
        Bounds: const Bounds.fromLTWH(100, 100, 100, 100),
      }));

      final result = await cell.invoke(
        const MoveEvent(
          position: Offset(50, 50),
        ),
      );
      expect(result, isA<InvokeDone>());
      expect(cell.state.plugin<Bounds>().position, const Offset(50, 50));
    });

    test('resize', () async {
      final cell = editor.create(TestCellModel.create({
        Bounds: const Bounds.fromLTWH(100, 100, 100, 100),
      }));

      final result = await cell.invoke(
        const ResizeEvent(
          delta: Offset(50, 50),
        ),
      );
      expect(result, isA<InvokeDone>());
      expect(cell.state.plugin<Bounds>().size, const Size(150, 150));
    });
  });
}
