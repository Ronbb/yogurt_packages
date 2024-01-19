import 'package:flutter/material.dart';
import 'package:yogurt_editor/yogurt_editor.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Example(),
      ),
    );
  }
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  late final EditorController controller;

  static int _nextId = 0;

  static int _id() => _nextId++;

  @override
  void initState() {
    super.initState();
    controller = EditorController(
      root: CellState(
        id: _id(),
        model: CustomCellModel(
          builder: (context, state) {
            return const SizedBox();
          },
        ),
      ),
    );

    controller.create(CellState(
      id: _id(),
      model: const NodeModel(),
      plugins: const {
        Bounds: Bounds.fromLTWH(100, 100, 100, 100),
      },
    ));

    controller.create(CellState(
      id: _id(),
      model: const NodeModel(),
      plugins: const {
        Bounds: Bounds.fromLTWH(250, 150, 100, 100),
      },
    ));
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditorView(
      controller: controller,
    );
  }
}

class NodeModel extends CellModelBase {
  const NodeModel();

  @override
  Widget build(BuildContext context, CellState state) {
    return const ColoredBox(
      color: Colors.blue,
    );
  }
}
