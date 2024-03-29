import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

class _IncreasePlugin extends PluginBase<EventBusBase<int>> {
  const _IncreasePlugin();

  @override
  void onCreate(EventBusBase<int> controller) {
    controller.on<int>((event, update) {
      update(controller.state + event);
    });
  }
}

class AsyncEventBusBenchmark extends AsyncBenchmarkBase {
  AsyncEventBusBenchmark() : super('AsyncYogurtEventBus');

  final eventBus = AsyncEventBus<int>(
    state: 0,
    plugins: const [_IncreasePlugin()],
  );

  @override
  Future<void> run() async {
    await eventBus.invoke(1);
  }

  @override
  Future<void> setup() async {}

  @override
  Future<void> teardown() async {}
}

class SyncEventBusBenchmark extends BenchmarkBase {
  SyncEventBusBenchmark() : super('SyncYogurtEventBus');

  final eventBus = SyncEventBus<int>(
    state: 0,
    plugins: const [_IncreasePlugin()],
  );

  @override
  void run() {
    eventBus.invoke(1);
  }

  @override
  void setup() {}

  @override
  void teardown() {}
}

void main() {
  AsyncEventBusBenchmark().report();
  SyncEventBusBenchmark().report();
}
