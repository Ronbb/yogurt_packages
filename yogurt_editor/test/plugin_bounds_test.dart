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
      expect(editor.root.children.value, isEmpty);

      watch(editor.root.children);

      final cell = editor.create(TestCellModel.create());

      expect(cell.state.plugin<Bounds>(), isNotNull);
    });

    test('move', () async {
      final cell = editor.create(TestCellModel.create({
        Bounds: const Bounds.fromLTWH(100, 100, 100, 100),
      }));
      expect(cell.state.plugin<Bounds>(), isNotNull);

      final result = await cell.invoke(
        const MoveEvent(
          delta: Offset(50, 50),
        ),
      );
      expect(result, isA<InvokeDone>());
      expect(cell.state.plugin<Bounds>().topLeft, const Offset(150, 150));
    });

    test('resize', () async {
      final cell = editor.create(TestCellModel.create({
        Bounds: const Bounds.fromLTWH(100, 100, 100, 100),
      }));
      expect(cell.state.plugin<Bounds>(), isNotNull);

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
