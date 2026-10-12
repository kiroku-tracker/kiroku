/// Ограничение частоты запросов.
class RateLimiter {
  RateLimiter({this.interval = const Duration(milliseconds: 250)});

  final Duration interval;
  Future<void> _tail = Future.value();
  DateTime _lastStart = DateTime.fromMillisecondsSinceEpoch(0);

  Future<T> run<T>(Future<T> Function() task) {
    final slot = _tail.then((_) async {
      final wait = _lastStart.add(interval).difference(DateTime.now());
      if (wait > Duration.zero) await Future<void>.delayed(wait);
      _lastStart = DateTime.now();
    });
    _tail = slot;
    return slot.then((_) => task());
  }
}
