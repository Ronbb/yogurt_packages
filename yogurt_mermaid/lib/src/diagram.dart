import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:petitparser/petitparser.dart';

part 'diagrams/flowchart.dart';

part 'parser_utils.dart';

part 'diagram.freezed.dart';

abstract class Diagram {
  const Diagram();

  Widget build(BuildContext context);
}

abstract class DiagramFactory {
  const DiagramFactory();

  Diagram create(String data);
}

mixin DiagramEquatable<T> on Diagram {
  T get data;

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other)
      ? true
      : (other.runtimeType != runtimeType
          ? false
          : (other.hashCode == hashCode));
}
