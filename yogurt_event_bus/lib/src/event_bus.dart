import 'dart:async';
import 'dart:collection';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_bus.freezed.dart';

part 'async_event_bus.dart';
part 'sync_event_bus.dart';
part 'event.dart';
part 'plugin.dart';
part 'state.dart';

typedef Disposable = void Function();

abstract class EventBusBase<State extends StateBase> {
  EventBusBase() {
    onCreate();
  }

  State get state;

  @protected
  @mustCallSuper
  void onCreate() {}

  @protected
  @visibleForTesting
  void update(State state);

  FutureOr<InvokeResult<State>> invoke<Event extends EventBase>(Event event);

  Disposable on<Event extends EventBase>(
    EventHandler<Event, State> handler, {
    HandlerPriority priority = HandlerPriority.medium,
  });

  @mustCallSuper
  FutureOr<void> onAfterInvoke<Event extends EventBase>(
      Event event, State previous);

  Disposable after<Event extends EventBase>(
    EventHandler<AfterEvent<Event, State>, State> handler, {
    HandlerPriority priority = HandlerPriority.medium,
  });

  @mustCallSuper
  Future<void> close() async {}
}
