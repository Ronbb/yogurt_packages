part of 'event_bus.dart';

abstract class PluginBase<Controller> {
  const PluginBase();

  void onCreate(Controller controller);
}
