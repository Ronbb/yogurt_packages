part of '../diagram.dart';

class FlowChart extends Diagram {
  const FlowChart();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class FlowChartGrammar extends GrammarDefinition {
  const FlowChartGrammar();

  @override
  Parser start() =>
      ref0(firstLine) &
      (ref0(flow) & newline().star()).pick(0).starForward(endOfInput()).end();

  Parser id() => noneOf('{}[]()| ').plus().flatten();

  Parser description() => noneOf('{}[]()|').plus().flatten();

  Parser firstLine() =>
      string('flowchart').trim() & word().plus().flatten().trim().optional();

  Parser element() =>
      ref0(id).trim() &
      (ref2(elementShape, '{', '}') |
              ref2(elementShape, '[', ']') |
              ref2(elementShape, '(', ')'))
          .optional();

  Parser elementShape(String start, String end) =>
      char(start) & ref0(description).trim() & char(end);

  Parser arrow() => string('-->') | string('--') | failure('expect arrow');

  Parser label() => (char('|') & ref0(description).trim() & char('|')).pick(1);

  Parser flow() =>
      ref0(element).trim() &
      ref0(arrow).trim() &
      ref0(label).trim().optional() &
      ref0(element).trim();
}

class FlowChartFactory extends DiagramFactory {
  const FlowChartFactory();

  @override
  FlowChart create(String data) {
    return const FlowChart();
  }
}
