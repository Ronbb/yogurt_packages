part of 'event_bus.dart';

abstract class PluginBase<Controller extends EventBus> {
  const PluginBase();

  void onCreate(Controller controller);
}
