part of 'event_bus.dart';

typedef Plugin<State extends StateBase>
    = PluginBase<State, PluginManager<State>>;

abstract class PluginBase<State extends StateBase,
    Controller extends PluginManager<State>> {
  const PluginBase();

  void onAttach(Controller controller);

  void onDetach(Controller controller);
}

typedef AutoDisposePlugin<State extends StateBase>
    = AutoDisposePluginBase<State, PluginManager<State>>;

abstract class AutoDisposePluginBase<State extends StateBase,
        Controller extends PluginManager<State>>
    extends PluginBase<State, Controller> with AutoDispose {
  const AutoDisposePluginBase();
}

mixin AutoDispose<State extends StateBase,
    Controller extends PluginManager<State>> on PluginBase<State, Controller> {
  Iterable<Disposable> onCreate(Controller controller);

  @override
  void onAttach(Controller controller) {
    final disposables = onCreate(controller).toList(growable: false);

    controller._setDisposables(this, disposables);
  }

  @override
  void onDetach(Controller controller) {
    final disposables = controller._getDisposables(this);
    for (var disposable in disposables) {
      disposable();
    }

    controller._setDisposables(this, []);
  }
}

mixin PluginManager<State extends Object> on EventBusBase<State> {
  List<Plugin<State>> _plugins = const [];

  final _disposables = <PluginBase, List<Disposable>>{};

  Iterable<Plugin<State>> get plugins => _plugins;

  set plugins(Iterable<Plugin<State>> plugins) {
    for (var plugin in _plugins) {
      detachPlugin(plugin);
    }

    _plugins = plugins.toList(growable: false);

    for (var plugin in _plugins) {
      attachPlugin(plugin);
    }
  }

  @protected
  void attachPlugin(Plugin<State> plugin) {
    plugin.onAttach(this);
  }

  @protected
  void detachPlugin(Plugin<State> plugin) {
    plugin.onDetach(this);
  }

  List<Disposable> _getDisposables(PluginBase plugin) {
    return _disposables[plugin] ?? [];
  }

  void _setDisposables(PluginBase plugin, List<Disposable> disposables) {
    _disposables[plugin] = disposables;
  }

  @override
  void onCreate() {
    for (var plugin in plugins) {
      attachPlugin(plugin);
    }
    super.onCreate();
  }

  @override
  Future<void> close() {
    for (var plugin in plugins) {
      detachPlugin(plugin);
    }
    return super.close();
  }
}
