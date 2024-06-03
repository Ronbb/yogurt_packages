import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('cell tree', () {
    test('add and remove', () async {
      final editor = createTestEditor(
        rootPlugins: const [
          CellTreePlugin(),
        ],
      );

      expect(editor.root.children, isEmpty);
      expect(editor.root.state<CellTreeState>().children, isEmpty);
      expect(editor.cells, hasLength(1));

      final cell = editor.createTest();
      expect(editor.root.children, hasLength(1));
      expect(editor.root.state<CellTreeState>().children, hasLength(1));
      expect(editor.cells, hasLength(2));
      expect(cell.parent, isNotNull);

      editor.remove(cell.id);
      expect(editor.root.children, isEmpty);
      expect(editor.cells, hasLength(1));
      expect(cell.parent, isNull);
    });
  });
}
