import 'dart:ui' as ui;

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
      all: const {
        Bounds: Bounds.fixed(
          left: 100,
          top: 100,
          width: 100,
          height: 100,
        ),
      },
    ));

    controller.create(CellState(
      id: _id(),
      model: const NodeModel(),
      all: const {
        Bounds: Bounds.fixed(
          left: 250,
          top: 150,
          width: 100,
          height: 100,
        ),
      },
    ));

    controller.create(
      CellState(
        id: _id(),
        model: const NodeModel(),
        all: const {
          String: 'inner text',
          Bounds: Bounds.intrinsic(
            top: 300,
            left: 300,
            delegate: IntrinsicBounds(),
          ),
        },
      ),
      extraPlugins: [
        const IntrinsicBoundsPlugin(
          delegate: IntrinsicBounds(),
        )
      ],
    );
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
    return ColoredBox(
      color: Colors.blue,
      child: state.has<String>() ? Text(state()) : null,
    );
  }
}

class IntrinsicBounds extends IntrinsicBoundsDelegate {
  const IntrinsicBounds();

  @override
  Size computeDryLayout(CellController controller) {
    final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
      fontSize: 14,
    ));

    builder.pushStyle(ui.TextStyle());
    builder.addText(controller.state<String>());

    final paragraph = builder.build();

    paragraph.layout(const ui.ParagraphConstraints(
      width: 120,
    ));

    return Size(paragraph.width, paragraph.height);
  }
}
