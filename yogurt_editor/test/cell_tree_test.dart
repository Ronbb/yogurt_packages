import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('cell tree', () {
    test('add and remove', () async {
      final editor = EditorController(
        state: const EditorState(),
        root: TestCellModel.create(
          plugins: [
            const CellTreePlugin(),
          ],
        ),
      );

      expect(editor.root.children, isEmpty);
      expect(editor.root.state<CellTreeState>().children, isEmpty);
      expect(editor.cells, hasLength(1));

      final cell = editor.create(TestCellModel.create());
      expect(editor.root.children, hasLength(1));
      expect(editor.root.state<CellTreeState>().children, hasLength(1));
      expect(editor.cells, hasLength(2));
      expect(cell.parent, isNotNull);

      editor.remove(cell.state.id);
      expect(editor.root.children, isEmpty);
      expect(editor.cells, hasLength(1));
      expect(cell.parent, isNull);
    });
  });
}
