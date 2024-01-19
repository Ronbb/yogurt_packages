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

class TestCellModel extends CellModelBase {
  const TestCellModel({
    this.plugins = const [],
    this.builder = defaultBuilder,
  });

  static var id = 0;

  static CellState create({
    Map<Type, dynamic> state = const {},
    List<CellPluginBase> plugins = const [],
  }) {
    return CellState(
      id: id++,
      model: TestCellModel(
        plugins: plugins,
      ),
      plugins: state,
    );
  }

  static Widget defaultBuilder(BuildContext context, CellState state) {
    return const SizedBox();
  }

  @override
  final List<CellPluginBase> plugins;

  final Widget Function(BuildContext context, CellState state) builder;

  @override
  Widget build(BuildContext context, CellState state) {
    return builder(context, state);
  }
}

extension TestEditorController on EditorController {
  CellController createTest({
    Map<Type, dynamic> state = const {},
    List<CellPluginBase> plugins = const [],
    CellController? parent,
    List<CellPluginBase> extraPlugins = const [],
  }) {
    return create(
      TestCellModel.create(
        state: state,
        plugins: plugins,
      ),
      parent: parent,
      extraPlugins: extraPlugins,
    );
  }
}
