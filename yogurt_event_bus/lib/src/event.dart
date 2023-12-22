part of 'event_bus.dart';

abstract class EventBase {
  const EventBase();
}

@freezed
class AfterEvent<Event extends EventBase, State extends StateBase>
    extends EventBase with _$AfterEvent<Event, State> {
  const AfterEvent._();

  const factory AfterEvent({
    required State previous,
    required State current,
    required Event event,
  }) = _AfterEvent<Event, State>;
}

typedef StateUpdater<State extends StateBase> = void Function(State state);

typedef EventHandler<Event extends EventBase, State extends StateBase>
    = FutureOr<void> Function(Event event, StateUpdater<State> update);

enum HandlerPriority implements Comparable<HandlerPriority> {
  max(4096),
  high(3072),
  medium(2048),
  low(1024),
  min(0);

  const HandlerPriority(this.priority);

  final int priority;

  @override
  int compareTo(HandlerPriority other) {
    return priority.compareTo(other.priority);
  }
}
