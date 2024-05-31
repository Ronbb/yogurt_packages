import 'package:flutter/widgets.dart';

import 'editor_controller.dart';

abstract class CellModelBase {
  const CellModelBase();

  List<CellPlugin> get plugins => const [];

  Widget build(BuildContext context, CellState state);
}

class CustomCellModel extends CellModelBase {
  const CustomCellModel({
    required this.builder,
    this.plugins = const [],
  });

  final Widget Function(BuildContext context, CellState state) builder;

  @override
  final List<CellPlugin> plugins;

  @override
  Widget build(BuildContext context, CellState state) {
    return builder(context, state);
  }
}
