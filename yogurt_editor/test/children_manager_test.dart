import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  test('children manager', () async {
    final editor = EditorController(
      state: const EditorState(),
      root: TestCellModel.create(),
    );

    expect(editor.root.children.value, isEmpty);

    watch(editor.root.children);

    final cell = editor.create(TestCellModel.create());
    expect(editor.root.children.value, hasLength(1));
    expect(cell.parent, isNotNull);
    expect(editor.root.children, hasNotified(1));

    editor.remove(cell.state.id);
    expect(editor.root.children.value, isEmpty);
    expect(cell.parent, isNull);
    expect(editor.root.children, hasNotified(2));
  });
}
