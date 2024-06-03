import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('view', () {
    testWidgets("basic", (tester) async {
      final editor = createTestEditor();

      final cell = editor.createTest(
        state: const {
          Bounds: Bounds.fixed(
            left: 100,
            top: 100,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [
          BoundsPlugin(),
        ],
        builder: (context, state) {
          return Container();
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditorView(
            controller: editor,
          ),
        ),
      );

      final widget = find.bySubtype<Container>();
      expect(widget, findsOne);

      final renderObject = tester.renderObject(widget);
      expect(renderObject, isA<RenderBox>());

      final size = (renderObject as RenderBox).size;
      expect(size, cell.state<Bounds>().size);
    });

    testWidgets("update by model", (tester) async {
      final editor = createTestEditor();

      final cell = editor.createTest(
        state: const {
          Bounds: Bounds.fixed(
            left: 100,
            top: 100,
            width: 100,
            height: 100,
          ),
        },
        plugins: const [
          BoundsPlugin(),
        ],
        builder: (context, state) {
          return Container(
            color: Colors.blue,
          );
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EditorView(
            controller: editor,
          ),
        ),
      );

      {
        final widget = find.bySubtype<Container>();
        expect(widget, findsOne);
        expect((tester.widget(widget) as Container).color, Colors.blue);
      }

      {
        final model = cell.testModel;
        model.builder = (context, state) {
          return Container(
            color: Colors.red,
          );
        };

        await tester.pump();

        final widget = find.bySubtype<Container>();
        expect(widget, findsOne);
        expect((tester.widget(widget) as Container).color, Colors.red);
      }
    });
  });
}
