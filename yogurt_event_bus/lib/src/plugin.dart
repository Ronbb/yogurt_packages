part of 'event_bus.dart';

abstract class PluginBase<State extends StateBase> {
  const PluginBase();

  void onCreate(EventBus<State> controller);
}
