import 'package:flutter_test/flutter_test.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

import 'test_utils.dart';

void main() {
  group('path', () {
    final editor = EditorController(
      state: const EditorState(),
      root: TestCellModel.create(),
      plugins: const [BoundsPlugin()],
    );

    test('rebuild', () async {
      final cell1 = editor.create(TestCellModel.create({
        Bounds: const Bounds.fromLTWH(0, 0, 100, 100),
      }));
      final connector1 = editor.create(
        TestCellModel.create({
          Bounds: const Bounds.fromLTWH(10, 10, 10, 10),
        }),
        parent: cell1,
      );

      final cell2 = editor.create(TestCellModel.create({
        Bounds: const Bounds.fromLTWH(200, 0, 100, 100),
      }));
      final connector2 = editor.create(
        TestCellModel.create({
          Bounds: const Bounds.fromLTWH(10, 10, 10, 10),
        }),
        parent: cell2,
      );

      final edge = editor.create(
        TestCellModel.create({
          EdgePath: EdgePath(
            sourceId: connector1.state.id,
            targetId: connector2.state.id,
          ),
        }),
        extraCellPlugins: const [CellPathPlugin()],
      );

      {
        final result = await edge.invoke(const PathRebuildEvent());
        expect(result, isA<InvokeDone>());

        final path = result.state.plugin<EdgePath>().path;
        expect(path, isNotNull);

        expect(
          path,
          isPathThat(
            includes: [
              connector1.editorBounds?.center ?? Offset.infinite,
              connector2.editorBounds?.center ?? Offset.infinite,
            ],
          ),
        );
      }
    });
  });
}
