import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yogurt_editor/yogurt_editor.dart';

export 'package:yogurt_editor/yogurt_editor.dart';

final _counts = HashMap<Listenable, int>.identity();
final _watchers = HashMap<Listenable, _Watcher>.identity();

void watch(Listenable listenable) {
  assert(!_watchers.containsKey(listenable), 'should not be watched again');

  final watcher = _Watcher(listenable);
  listenable.addListener(watcher.call);
  _watchers[listenable] = watcher;
  _counts[listenable] = 0;
}

void unwatch(Listenable listenable) {
  final watcher = _watchers[listenable];
  if (watcher != null) {
    listenable.removeListener(watcher.call);
  }
}

void rewatch(Listenable listenable) {
  assert(_watchers.containsKey(listenable), 'should be watched ahead');
  _counts[listenable] = 0;
}

class _Watcher {
  const _Watcher(this.listenable);

  final Listenable listenable;

  void call() {
    _counts[listenable] = (_counts[listenable] ?? 0) + 1;
  }
}

Matcher hasNotified([int? count]) => _HasNotified(count);

class _HasNotified extends Matcher {
  final int? _count;
  const _HasNotified(this._count);

  @override
  bool matches(Object? item, Map matchState) {
    try {
      final count = _counts[item];
      if (_count == null) {
        return count != null && count > 0;
      }

      return _count == count;
    } catch (e) {
      return false;
    }
  }

  @override
  Description describe(Description description) =>
      description.add('an Listenable has been notified for $_count times');

  @override
  Description describeMismatch(Object? item, Description mismatchDescription,
      Map matchState, bool verbose) {
    try {
      final count = _counts[item];
      return mismatchDescription.add('has length of ').addDescriptionOf(count);
    } catch (e) {
      return mismatchDescription.add("isn't watched");
    }
  }
}

class TestCellModel extends CellModel {
  TestCellModel({
    List<CellPlugin> plugins = const [],
    Widget Function(BuildContext context, CellState state)? builder,
  })  : _builder = builder,
        _plugins = plugins;

  static var _id = 0;

  static int nextId() => _id++;

  static Widget defaultBuilder(BuildContext context, CellState state) {
    return const SizedBox();
  }

  final List<CellPlugin> _plugins;

  @override
  List<CellPlugin> get plugins => _plugins;
  set plugins(List<CellPlugin> value) {
    _plugins.clear();
    _plugins.addAll(value);
    notifyListeners();
  }

  Widget Function(BuildContext context, CellState state)? _builder;
  Widget Function(BuildContext context, CellState state)? get builder =>
      _builder;
  set builder(Widget Function(BuildContext context, CellState state)? value) {
    _builder = value;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context, CellState state) {
    return (_builder ?? defaultBuilder)(context, state);
  }
}

EditorController createTestEditor({
  List<CellPlugin> rootPlugins = const [],
  List<EditorPlugin> plugins = const [],
}) {
  return EditorController(
    rootModel: TestCellModel(
      plugins: rootPlugins,
    ),
    plugins: plugins,
  );
}

extension TestEditorController on EditorController {
  CellController createTest({
    dynamic id,
    Map<Type, dynamic> state = const {},
    List<CellPlugin> plugins = const [],
    CellController? parent,
    List<CellPlugin> extraPlugins = const [],
    Widget Function(BuildContext context, CellState state)? builder,
  }) {
    return create(
      id: id ?? TestCellModel.nextId(),
      model: TestCellModel(
        plugins: plugins,
        builder: builder,
      ),
      state: CellState(state),
      parent: parent,
      extraPlugins: extraPlugins,
    );
  }
}

extension TestCellController on CellController {
  TestCellModel get testModel => model as TestCellModel;
}
