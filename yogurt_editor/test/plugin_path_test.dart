import 'package:flutter_test/flutter_test.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

import 'test_utils.dart';

void main() {
  group('path', () {
    final editor = EditorController(
      state: const EditorState(),
      root: TestCellModel.create(),
    );

    test('rebuild', () async {
      final cell1 = editor.createTest(
        state: {
          Bounds: const Bounds.fromLTWH(0, 0, 100, 100),
        },
        plugins: const [BoundsPlugin()],
      );
      final connector1 = editor.createTest(
        state: {
          Bounds: const Bounds.fromLTWH(10, 10, 10, 10),
        },
        plugins: const [BoundsPlugin()],
        parent: cell1,
      );

      final cell2 = editor.createTest(
        state: {
          Bounds: const Bounds.fromLTWH(200, 0, 100, 100),
        },
        plugins: const [BoundsPlugin()],
      );
      final connector2 = editor.createTest(
        state: {
          Bounds: const Bounds.fromLTWH(10, 10, 10, 10),
        },
        plugins: const [BoundsPlugin()],
        parent: cell2,
      );

      final edge = editor.createTest(
        state: {
          EdgePath: EdgePath(
            sourceId: connector1.state.id,
            targetId: connector2.state.id,
          ),
        },
        extraPlugins: const [PathPlugin()],
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

    test('auto-rebuild', () async {
      final cell1 = editor.createTest(
        state: {
          Bounds: const Bounds.fromLTWH(0, 0, 100, 100),
        },
        plugins: const [BoundsPlugin()],
      );
      final connector1 = editor.createTest(
        state: {
          Bounds: const Bounds.fromLTWH(10, 10, 10, 10),
        },
        plugins: const [BoundsPlugin()],
        parent: cell1,
      );

      final cell2 = editor.createTest(
        state: {
          Bounds: const Bounds.fromLTWH(200, 0, 100, 100),
        },
        plugins: const [BoundsPlugin()],
      );
      final connector2 = editor.createTest(
        state: {
          Bounds: const Bounds.fromLTWH(10, 10, 10, 10),
        },
        plugins: const [BoundsPlugin()],
        parent: cell2,
      );

      final edge = editor.createTest(
        state: {
          EdgePath: EdgePath(
            sourceId: connector1.state.id,
            targetId: connector2.state.id,
          ),
        },
        extraPlugins: const [PathPlugin()],
      );

      {
        final result = await edge.invoke(const PathRebuildEvent());
        expect(result, isA<InvokeDone>());

        final path = edge.state.plugin<EdgePath>().path;
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

      {
        await cell1.invoke(const MoveRelativeEvent(
          delta: Offset(320, 480),
        ));

        final path = edge.state.plugin<EdgePath>().path;
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
