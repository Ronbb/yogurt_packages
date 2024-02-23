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
    [
      ['flowchart', 'TD'],
      [
        [
          [
            'A',
            ['[', 'Christmas', ']']
          ],
          '-->',
          'Get money',
          [
            'B',
            ['(', 'Go shopping', ')']
          ]
        ],
        [
          ['B', null],
          '-->',
          null,
          [
            'C',
            ['{', 'Let me think', '}']
          ]
        ],
        [
          ['C', null],
          '-->',
          'One',
          [
            'D',
            ['[', 'Laptop', ']']
          ]
        ],
        [
          ['C', null],
          '-->',
          'Two',
          [
            'E',
            ['[', 'iPhone', ']']
          ]
        ],
        [
          ['C', null],
          '-->',
          'Three',
          [
            'F',
            ['[', 'fa:fa-car Car', ']']
          ]
        ]
      ]
    ]
  )
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
