import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('path', () {
    final editor = createTestEditor();

    test('rebuild', () async {
      final cell1 = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 0,
            top: 0,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [BoundsPlugin()],
      );
      final connector1 = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 10,
            top: 10,
            width: 10,
            height: 10,
          ),
        },
        plugins: const [BoundsPlugin()],
        parent: cell1,
      );

      final cell2 = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 200,
            top: 0,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [BoundsPlugin()],
      );
      final connector2 = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 10,
            top: 10,
            width: 10,
            height: 10,
          ),
        },
        plugins: const [BoundsPlugin()],
        parent: cell2,
      );

      final edge = editor.createTest(
        state: {
          EdgePath: EdgePath(
            sourceId: connector1.id,
            targetId: connector2.id,
          ),
        },
        extraPlugins: const [PathPlugin()],
      );

      {
        final result = edge.invoke(const PathRebuildEvent());
        expect(result, isA<InvokeDone>());

        final path = result.state<EdgePath>().path;
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
          Bounds: const Bounds.fixed(
            left: 0,
            top: 0,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [BoundsPlugin()],
      );
      final connector1 = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 10,
            top: 10,
            width: 10,
            height: 10,
          ),
        },
        plugins: const [BoundsPlugin()],
        parent: cell1,
      );

      final cell2 = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 200,
            top: 0,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [BoundsPlugin()],
      );
      final connector2 = editor.createTest(
        state: {
          Bounds: const Bounds.fixed(
            left: 10,
            top: 10,
            width: 10,
            height: 10,
          ),
        },
        plugins: const [BoundsPlugin()],
        parent: cell2,
      );

      final edge = editor.createTest(
        state: {
          EdgePath: EdgePath(
            sourceId: connector1.id,
            targetId: connector2.id,
          ),
        },
        extraPlugins: const [PathPlugin()],
      );

      {
        final result = edge.invoke(const PathRebuildEvent());
        expect(result, isA<InvokeDone>());

        final path = edge.state<EdgePath>().path;
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
        cell1.invoke(const MoveRelativeEvent(
          delta: Offset(320, 480),
        ));

        final path = edge.state<EdgePath>().path;
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
