import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yogurt_editor/yogurt_editor.dart';

import 'test_utils.dart';

class _TestCellModel extends CellModelBase {
  const _TestCellModel();

  static var id = 0;

  static CellState create() {
    return CellState(
      id: id++,
      model: const _TestCellModel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

void main() {
  test('children manager', () async {
    final editor = EditorController(
      state: const EditorState(),
      root: _TestCellModel.create(),
    );

    expect(editor.root.children.value, isEmpty);

    watch(editor.root.children);

    final cell = editor.create(_TestCellModel.create());
    expect(editor.root.children.value, hasLength(1));
    expect(cell.parent, isNotNull);
    expect(editor.root.children, hasNotified(1));

    editor.remove(cell.state.id);
    expect(editor.root.children.value, isEmpty);
    expect(cell.parent, isNull);
    expect(editor.root.children, hasNotified(2));
  });
}
