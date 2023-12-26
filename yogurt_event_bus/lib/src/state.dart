part of 'event_bus.dart';

abstract class StateBase {
  const StateBase();
}

@freezed
class InvokeResult<State extends StateBase> with _$InvokeResult<State> {
  const factory InvokeResult.done({
    required State state,
  }) = InvokeDone<State>;

  const factory InvokeResult.unhandled({
    required State state,
  }) = InvokeUnhandled<State>;

  const factory InvokeResult.error({
    required State state,
    required Object? error,
    required StackTrace stackTrace,
  }) = InvokeError<State>;
}
