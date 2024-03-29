import 'dart:async';
import 'dart:collection';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_bus.freezed.dart';

part 'async_event_bus.dart';
part 'sync_event_bus.dart';
part 'event.dart';
part 'plugin.dart';
part 'state.dart';

abstract class EventBusBase<State extends StateBase> {
  const EventBusBase();

  State get state;

  @protected
  @visibleForTesting
  void update(State state);

  FutureOr<InvokeResult<State>> invoke<Event extends EventBase>(Event event);

  void on<Event extends EventBase>(
    EventHandler<Event, State> handler, {
    HandlerPriority priority = HandlerPriority.medium,
  });

  @mustCallSuper
  FutureOr<void> onAfterInvoke<Event extends EventBase>(
      Event event, State previous);

  void after<Event extends EventBase>(
    EventHandler<AfterEvent<Event, State>, State> handler, {
    HandlerPriority priority = HandlerPriority.medium,
  });

  Future<void> close();
}
