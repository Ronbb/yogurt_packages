import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('bounds', () {
    test('bounds initial', () async {
      final editor = EditorController(
        state: const EditorState(),
        root: TestCellModel.create(),
        plugins: const [BoundsPlugin()],
      );

      expect(editor.root.children.value, isEmpty);

      watch(editor.root.children);

      final cell = editor.create(TestCellModel.create());
      expect(cell.state.plugin<Bounds>(), isNotNull);
    });
  });
}
