import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('view', () {
    testWidgets("basic", (tester) async {
      final editor = EditorController(
        state: const EditorState(),
        root: TestCellModel.create(),
      );

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

      await tester.pumpWidget(EditorView(
        controller: editor,
      ));

      final widget = find.bySubtype<Container>();
      expect(widget, findsOne);

      final renderObject = tester.renderObject(widget);
      expect(renderObject, isA<RenderBox>());

      final size = (renderObject as RenderBox).size;
      expect(size, cell.state.plugin<Bounds>().size);
    });
  });
}
