part of 'event_bus.dart';

class SyncEventBus<State extends StateBase> extends EventBusBase<State> {
  SyncEventBus({
    required State state,
    List<PluginBase<EventBusBase<State>>> plugins = const [],
  })  : _state = state,
        _plugins = plugins {
    _stateController.add(state);
    for (final plugin in _plugins) {
      plugin.onCreate(this);
    }
  }

  final _stateController = StreamController<State>.broadcast(sync: true);

  final _eventHandlers = <Type, List<_EventHandler>>{};

  final List<PluginBase<EventBusBase<State>>> _plugins;
  List<PluginBase<EventBusBase<State>>> get plugins =>
      _plugins is UnmodifiableListView
          ? _plugins
          : UnmodifiableListView(_plugins);

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
  InvokeResult<State> invoke<Event extends EventBase>(Event event) {
    if (isClosed) {
      throw Exception('EventBus is closed.');
    }

    final handlers = _eventHandlers[Event];

    if (handlers == null || handlers.isEmpty) {
      return InvokeResult.unhandled(
        state: state,
      );
    }

    final previous = state;

    try {
      for (var _EventHandler(:handler) in handlers) {
        handler(event);
      }

      onAfterInvoke(event, previous);
    } catch (e, stackTrace) {
      return InvokeResult.error(
        state: state,
        error: e,
        stackTrace: stackTrace,
      );
    }

    return InvokeResult.done(
      state: state,
    );
  }

  @override
  void on<Event extends EventBase>(
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
  }

  @override
  void onAfterInvoke<Event extends EventBase>(Event event, State previous) {
    if (event is AfterEvent) {
      return;
    }

    invoke(AfterEvent(
      current: state,
      previous: previous,
      event: event,
    ));
  }

  @override
  void after<Event extends EventBase>(
    EventHandler<AfterEvent<Event, State>, State> handler, {
    HandlerPriority priority = HandlerPriority.medium,
  }) {
    on<AfterEvent<Event, State>>(handler);
  }

  @override
  Future<void> close() async {
    await _stateController.close();
  }
}
