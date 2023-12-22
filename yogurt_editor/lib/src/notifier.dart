import 'package:flutter/foundation.dart';

class UnmodifiedValueNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  UnmodifiedValueNotifier(T value) : _value = value;

  final T _value;

  void notify() {
    super.notifyListeners();
  }

  @override
  T get value => _value;
}
