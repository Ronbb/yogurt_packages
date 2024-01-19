import 'package:flutter/widgets.dart';

import 'editor_controller.dart';

abstract class CellModelBase {
  const CellModelBase();

  Widget build(BuildContext context, CellState state);
}

class CustomCellModel extends CellModelBase {
  const CustomCellModel({required this.builder});

  final Widget Function(BuildContext context, CellState state) builder;

  @override
  Widget build(BuildContext context, CellState state) {
    return builder(context, state);
  }
}
