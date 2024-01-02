part of 'plugins.dart';

@freezed
class CellTreeEvent extends EventBase with _$CellTreeEvent {
  const CellTreeEvent._();

  const factory CellTreeEvent.create({
    required dynamic state,
  }) = CreateCellEvent;

  const factory CellTreeEvent.remove({
    required dynamic id,
    CellState? state,
  }) = RemoveCellEvent;
}
