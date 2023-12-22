import 'dart:collection';

import 'package:freezed_annotation/freezed_annotation.dart';

class PluginState {
  const PluginState({
    Map<Type, dynamic> states = const {},
  }) : _states = states;

  final Map<Type, dynamic> _states;

  Map<Type, dynamic> get states =>
      _states is UnmodifiableMapView ? _states : UnmodifiableMapView(_states);

  T? state<T>() {
    final state = _states[T];
    return state is T ? state : null;
  }

  PluginState update<T>(T state) {
    return PluginState(
      states: Map.of(_states)..[T] = state,
    );
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(_states);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginState &&
            const DeepCollectionEquality().equals(_states, other._states));
  }
}
