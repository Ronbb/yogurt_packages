part of 'event_bus.dart';

class AsyncEventBus<State extends StateBase> extends EventBusBase<State>
    with PluginManager<State> {
  AsyncEventBus({
    required State state,
    List<Plugin<State>> plugins = const [],
  }) : _state = state {
    _stateController.add(state);
    this.plugins = plugins;
  }

  final _eventController = StreamController<EventBase>.broadcast();
  final _stateController = StreamController<State>.broadcast();

  final _eventCompleters =
      LinkedHashMap<EventBase, Completer<InvokeResult<State>>>.identity();
  final _eventHandlers = <Type, List<_EventHandler>>{};
  final _eventSubscriptions = <Type, StreamSubscription>{};

  State _state;
  @override
  State get state => _state;

  Stream<State> get stream => _stateController.stream;
  bool get isClosed => _stateController.isClosed;

  @override
  void update(State state) {
    if (isClosed) {
      throw Exception('EventBus is closed.');
    }

    if (_state == state) {
      return;
    }

    _state = state;
    _stateController.add(state);
  }

  @override
  Future<InvokeResult<State>> invoke<Event extends EventBase>(Event event) {
    if (isClosed) {
      throw Exception('EventBus is closed.');
    }

    if (_eventHandlers[Event]?.isEmpty ?? true) {
      return Future.value(InvokeResult.unhandled(
        state: state,
      ));
    }

    final completer = Completer<InvokeResult<State>>();
    _eventCompleters[event] = completer;
    _eventController.add(event);

    return completer.future;
  }

  @override
  Disposable on<Event extends EventBase>(
    EventHandler<Event, State> handler, {
    HandlerPriority priority = HandlerPriority.medium,
  }) {
    final h = _EventHandler(
      (event) {
        return handler(event as Event, update);
      },
      priority,
    );

    final handlers = _eventHandlers[Event] ?? [];
    _eventHandlers[Event] = List.of(handlers)
      ..add(h)
      ..sort();

    if (!_eventSubscriptions.containsKey(Event)) {
      _eventSubscriptions[Event] = _eventController.stream
          .where((event) => event is Event)
          .cast<Event>()
          .asyncMap(
        (event) async {
          final previous = state;

          final handlers = _eventHandlers[Event];
          if (handlers == null) {
            return;
          }

          try {
            for (var _EventHandler(:handler) in handlers) {
              await handler(event);
            }

            if (!isClosed) {
              await onAfterInvoke(event, previous);
            }

            _eventCompleters[event]?.complete(InvokeResult.done(
              state: state,
            ));
          } catch (e, stackTrace) {
            _eventCompleters[event]?.complete(InvokeResult.error(
              state: state,
              error: e,
              stackTrace: stackTrace,
            ));
          }
        },
      ).listen(null);
    }

    return () {
      final handlers = _eventHandlers[Event];
      if (handlers == null) {
        return;
      }

      _eventHandlers[Event] = List.of(handlers)..remove(h);
    };
  }

  @override
  Future<void> onAfterInvoke<Event extends EventBase>(
      Event event, State previous) async {
    if (event is AfterEvent) {
      return;
    }

    await invoke(AfterEvent(
      current: state,
      previous: previous,
      event: event,
    ));
  }

  @override
  Disposable after<Event extends EventBase>(
    EventHandler<AfterEvent<Event, State>, State> handler, {
    HandlerPriority priority = HandlerPriority.medium,
  }) {
    return on<AfterEvent<Event, State>>(handler);
  }

  @override
  Future<void> close() async {
    await _eventController.close();
    await _stateController.close();
    for (var subscription in _eventSubscriptions.values) {
      await subscription.cancel();
    }
    for (var completer in _eventCompleters.values) {
      await completer.future;
    }

    return super.close();
  }
}

class _EventHandler implements Comparable<_EventHandler> {
  const _EventHandler(this.handler, this.priority);

  final FutureOr<void> Function(dynamic) handler;

  final HandlerPriority priority;

  @override
  int compareTo(_EventHandler other) {
    return other.priority.compareTo(priority);
  }
}
