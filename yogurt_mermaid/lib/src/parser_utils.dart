part of 'diagram.dart';

extension ForwardRepeatingParserExtension<R> on Parser<R> {
  @useResult
  Parser<List<R>> starForward(Parser<void> limit) =>
      repeatForward(limit, 0, unbounded);

  @useResult
  Parser<List<R>> plusForward(Parser<void> limit) =>
      repeatForward(limit, 1, unbounded);

  @useResult
  Parser<List<R>> repeatForward(Parser<void> limit, int min, int max) =>
      ForwardRepeatingParser<R>(this, limit, min, max);
}

class ForwardRepeatingParser<R> extends LimitedRepeatingParser<R> {
  ForwardRepeatingParser(
    super.parser,
    super.limit,
    super.min,
    super.max,
  );

  @override
  Parser<List<R>> copy() =>
      ForwardRepeatingParser<R>(delegate, limit, min, max);

  @override
  Result<List<R>> parseOn(Context context) {
    var current = context;
    final elements = <R>[];
    while (elements.length < min) {
      final result = delegate.parseOn(current);
      if (result is Failure) {
        return result;
      }
      elements.add(result.value);
      current = result;
    }
    final contexts = <Context>[current];
    while (elements.length < max) {
      final result = delegate.parseOn(current);
      if (result is Failure) {
        final limiter = limit.parseOn(current);
        if (limiter is Failure) {
          return result;
        }
        break;
      }
      elements.add(result.value);
      contexts.add(current = result);
    }

    return current.success(elements);
  }

  @override
  int fastParseOn(String buffer, int position) {
    var count = 0;
    var current = position;
    while (count < min) {
      final result = delegate.fastParseOn(buffer, current);
      if (result < 0) return -1;
      current = result;
      count++;
    }
    final positions = <int>[current];
    while (count < max) {
      final result = delegate.fastParseOn(buffer, current);
      if (result < 0) break;
      positions.add(current = result);
      count++;
    }
    for (;;) {
      final limiter = limit.fastParseOn(buffer, positions.last);
      if (limiter < 0) {
        if (count == 0) return -1;
        positions.removeLast();
        count--;
        if (positions.isEmpty) return -1;
      } else {
        return positions.last;
      }
    }
  }
}
