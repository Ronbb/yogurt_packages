part of '../diagram.dart';

class FlowChart extends Diagram with DiagramEquatable<FlowChartData> {
  const FlowChart({
    required this.data,
  });

  @override
  final FlowChartData data;

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

@freezed
class FlowChartData with _$FlowChartData {
  const FlowChartData._();

  const factory FlowChartData({
    required FlowChartHeader header,
    required List<FlowChartFlow> flows,
  }) = _FlowChartData;

  const factory FlowChartData.header({
    required String type,
    required String? direction,
  }) = FlowChartHeader;

  const factory FlowChartData.flow({
    required FlowChartElement start,
    required FlowChartElement end,
    String? label,
    required String arrow,
  }) = FlowChartFlow;

  const factory FlowChartData.element({
    required String id,
    final String? description,
    final String? shape,
  }) = FlowChartElement;
}

class FlowChartGrammar extends GrammarDefinition<FlowChart> {
  const FlowChartGrammar();

  @override
  Parser<FlowChart> start() => (ref0(firstLine) &
              (ref0(flow) & newline().star())
                  .pick(0)
                  .starForward(endOfInput())
                  .castList<FlowChartFlow>()
                  .end())
          .map((list) {
        if (list case [FlowChartHeader header, List<FlowChartFlow> flows]) {
          return FlowChart(
            data: FlowChartData(
              header: header,
              flows: flows,
            ),
          );
        }

        throw Exception("create flow chart error");
      });

  Parser<String> id() => noneOf('{}[]()| ').plus().flatten();

  Parser<String> description() => noneOf('{}[]()|').plus().flatten();

  Parser<FlowChartHeader> firstLine() =>
      (string('flowchart').trim() & word().plus().flatten().trim().optional())
          .map(
        (list) {
          if (list case [String type, String? description]) {
            return FlowChartHeader(
              type: type,
              direction: description,
            );
          }
          throw Exception("create header error");
        },
      );

  Parser<FlowChartElement> element() => (ref0(id).trim() &
              (ref2(elementShape, '{', '}') |
                      ref2(elementShape, '[', ']') |
                      ref2(elementShape, '(', ')'))
                  .optional())
          .map(
        (list) {
          if (list
              case [
                String id,
                [String? start, String? description, String? end]
              ]) {
            return FlowChartElement(
              id: id,
              description: description,
              shape: start != null ? '$start$end' : null,
            );
          } else if (list case [String id, null]) {
            return FlowChartElement(
              id: id,
            );
          }

          throw Exception("create element error");
        },
      );

  Parser elementShape(String start, String end) =>
      char(start) & ref0(description).trim() & char(end);

  Parser arrow() => (string('-->') | string('--') | failure('expect arrow'));

  Parser label() => (char('|') & ref0(description).trim() & char('|')).pick(1);

  Parser<FlowChartFlow> flow() => (ref0(element).trim() &
              ref0(arrow).trim() &
              ref0(label).trim().optional() &
              ref0(element).trim())
          .map(
        (list) {
          if (list
              case [
                FlowChartElement start,
                String arrow,
                String? label,
                FlowChartElement end,
              ]) {
            return FlowChartFlow(
              start: start,
              end: end,
              label: label,
              arrow: arrow,
            );
          }

          throw Exception("create flow error");
        },
      );
}

class FlowChartFactory extends DiagramFactory {
  const FlowChartFactory();

  @override
  FlowChart create(String data) {
    final parser = const FlowChartGrammar().build();

    return parser.parse(data).value;
  }
}
