import 'package:flutter/widgets.dart';
import 'package:yogurt_editor/src/editor_controller.dart';
import 'package:yogurt_editor/src/views/cell_view.dart';

class EditorView extends StatefulWidget {
  const EditorView({
    super.key,
    required this.controller,
  });

  final EditorController controller;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return CellView(
      controller: controller.root,
    );
  }
}
