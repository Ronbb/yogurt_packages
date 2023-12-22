part of 'event_bus.dart';

abstract class PluginBase {
  const PluginBase();

  void onCreate(EventBus controller);
}
