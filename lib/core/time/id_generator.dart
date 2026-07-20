abstract interface class IdGenerator {
  String next();
}

/// A deterministic adapter used until a future milestone supplies a durable
/// identifier implementation. Tests can inject the same port with known IDs.
final class DeterministicIdGenerator implements IdGenerator {
  DeterministicIdGenerator({required this.prefix, int initialValue = 0})
    : _nextValue = initialValue;

  final String prefix;
  int _nextValue;

  @override
  String next() {
    final value = '$prefix-$_nextValue';
    _nextValue += 1;
    return value;
  }
}
