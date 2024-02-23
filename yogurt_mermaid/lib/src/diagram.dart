import 'package:flutter/widgets.dart';
import 'package:petitparser/petitparser.dart';
import 'package:meta/meta.dart';

part 'diagrams/flowchart.dart';

part 'parser_utils.dart';

abstract class Diagram {
  const Diagram();

  Widget build(BuildContext context);
}

abstract class DiagramFactory {
  const DiagramFactory();

  Diagram create(String data);
}
