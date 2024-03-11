import 'package:flutter_test/flutter_test.dart';
import 'package:yogurt_mermaid/yogurt_mermaid.dart';

const cases = <(String, Object?)>[
  (
    """
flowchart TD
    A[Christmas] -->|Get money| B(Go shopping)
    B --> C{Let me think}
    C -->|One| D[Laptop]
    C -->|Two| E[iPhone]
    C -->|Three| F[fa:fa-car Car]
""",
    FlowChart(
      data: FlowChartData(
        header: FlowChartHeader(
          type: 'flowchart',
          direction: 'TD',
        ),
        flows: [
          FlowChartFlow(
            start: FlowChartElement(
              id: 'A',
              description: 'Christmas',
              shape: '[]',
            ),
            end: FlowChartElement(
              id: 'B',
              description: 'Go shopping',
              shape: '()',
            ),
            label: 'Get money',
            arrow: '-->',
          ),
          FlowChartFlow(
            start: FlowChartElement(
              id: 'B',
            ),
            end: FlowChartElement(
              id: 'C',
              description: 'Let me think',
              shape: '{}',
            ),
            arrow: '-->',
          ),
          FlowChartFlow(
            start: FlowChartElement(
              id: 'C',
            ),
            end: FlowChartElement(
              id: 'D',
              description: 'Laptop',
              shape: '[]',
            ),
            arrow: '-->',
            label: 'One',
          ),
          FlowChartFlow(
            start: FlowChartElement(
              id: 'C',
            ),
            end: FlowChartElement(
              id: 'E',
              description: 'iPhone',
              shape: '[]',
            ),
            arrow: '-->',
            label: 'Two',
          ),
          FlowChartFlow(
            start: FlowChartElement(
              id: 'C',
            ),
            end: FlowChartElement(
              id: 'F',
              description: 'fa:fa-car Car',
              shape: '[]',
            ),
            arrow: '-->',
            label: 'Three',
          ),
        ],
      ),
    ),
  ),
];

void main() {
  group('flowchart', () {
    test('grammar', () {
      const grammar = FlowChartGrammar();
      final parser = grammar.build();
      for (final (data, result) in cases) {
        expect(parser.parse(data).value, result);
      }
    });
  });
}
