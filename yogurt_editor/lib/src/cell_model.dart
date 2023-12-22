import 'package:flutter/widgets.dart';

abstract class CellModelBase {
  const CellModelBase();

  Widget build(BuildContext context);
}

class CustomCellModel extends CellModelBase {
  const CustomCellModel({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return build(context);
  }
}
