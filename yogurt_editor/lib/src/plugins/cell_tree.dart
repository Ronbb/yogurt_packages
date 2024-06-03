part of 'plugins.dart';

@freezed
class CellTreeEvent extends EventBase with _$CellTreeEvent {
  const CellTreeEvent._();

  const factory CellTreeEvent.add({
    required dynamic id,
  }) = AddCellEvent;

  const factory CellTreeEvent.remove({
    required dynamic id,
  }) = RemoveCellEvent;
}

@freezed
class CellTreeState with _$CellTreeState {
  const CellTreeState._();

  const factory CellTreeState({
    @Default(<dynamic>[]) List<dynamic> children,
  }) = _CellTreeState;
}

class CellTreePlugin extends CellPlugin {
  const CellTreePlugin();

  @override
  Iterable<Disposable> onCreate(CellController controller) sync* {
    controller.initializePluginState((_) => const CellTreeState());

    yield controller.on<AddCellEvent>((event, update) {
      update(controller.state.rebuild((CellTreeState state) {
        return state.copyWith(
          children: [...state.children, event.id],
        );
      }));
    });

    yield controller.on<RemoveCellEvent>((event, update) {
      update(controller.state.rebuild((CellTreeState state) {
        return state.copyWith(
          children: state.children.where((id) => id != event.id).toList(),
        );
      }));
    });
  }

  @override
  void onChildAdded(CellController controller, CellController child) {
    controller.invoke(AddCellEvent(
      id: child.id,
    ));
  }

  @override
  void onChildRemoved(CellController controller, CellController child) {
    controller.invoke(RemoveCellEvent(
      id: child.id,
    ));
  }
}
