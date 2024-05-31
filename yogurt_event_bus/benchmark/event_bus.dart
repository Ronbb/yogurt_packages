import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:yogurt_event_bus/yogurt_event_bus.dart';

class _IncreasePlugin extends AutoDisposePlugin<int> {
  _IncreasePlugin();

  @override
  Iterable<Disposable> onCreate(EventBusBase<int> controller) sync* {
    yield controller.on<int>((event, update) {
      update(controller.state + event);
    });
  }
}

class AsyncEventBusBenchmark extends AsyncBenchmarkBase {
  AsyncEventBusBenchmark() : super('AsyncYogurtEventBus');

  final eventBus = AsyncEventBus<int>(
    state: 0,
    plugins: [_IncreasePlugin()],
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
    plugins: [_IncreasePlugin()],
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
