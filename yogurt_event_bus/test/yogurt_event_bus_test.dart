import 'package:flutter_test/flutter_test.dart';

import 'package:yogurt_event_bus/yogurt_event_bus.dart';

mixin _TestValue {
  Object? get value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    return runtimeType == other.runtimeType && value.hashCode == other.hashCode;
  }
}

class _TestState extends StateBase with _TestValue {
  const _TestState([this.value]);

  @override
  final Object? value;
}

class _TestEvent extends EventBase with _TestValue {
  const _TestEvent([this.value]);

  @override
  final Object? value;
}

class _TestPlugin extends PluginBase {
  const _TestPlugin();

  @override
  void onCreate(EventBus controller) {
    controller.on<_TestEvent>((event, update) {
      update(_TestState(event.value));
    });
  }
}

void main() {
  test('event bus', () async {
    final bus = EventBus(
      state: const _TestState(null),
      plugins: [const _TestPlugin()],
    );

    final result = await bus.invoke(const _TestEvent(null));
    expect(result, isA<InvokeDone>());
  });
}
