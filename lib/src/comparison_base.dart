/// A comparison function, which imposes a *total ordering* on some collection
/// of objects.
///
/// Comparators can be passed to a sort method (such as [List.sort]) to allow
/// precise control over the sort order. Comparators can also be used to control
/// the order of certain data structures or to provide an ordering for collections
/// of objects that don't have a [Comparable] natural ordering.
///
/// The ordering imposed by a comparator `c` on a set of elements `S` is said to
/// be *consistent with equals* if and only if `c.compare(e1, e2) == 0` has the
/// same boolean value as `e1.equals(e2)` for every `e1` and `e2` in `S`.
///
/// To more information, see [Comparator.java](https://github.com/frohoff/jdk8u-jdk/blob/master/src/share/classes/java/util/Comparator.java).
abstract class Comparator<T> {
  /// Create a [Comparator] from an anonymous function.
  const factory Comparator.from(
    int Function(T, T) compare,
  ) = _ComparatorFromFunction;

  /// Returns a comparator that compares [Comparable] objects in natural order.
  static Comparator<T> naturalOrder<T extends Comparable<T>>() {
    return _NaturalOrderComparator();
  }

  /// Returns a comparator that imposes the reverse of the natural ordering.
  static Comparator<T> reverseOrder<T extends Comparable<T>>() {
    return _ReverseOrderComparator();
  }

  /// Accepts a [keyExtractor] that extracts a [Comparable] sort key from a type [I]
  /// and returns a [Comparator] that compares by that sort key.
  static Comparator<I> comparingBy<I, O extends Comparable<O>>(
    O Function(I) keyExtractor,
  ) {
    return _ComparingKeyComparator(keyExtractor);
  }

  /// Accepts a [keyExtractor] that extracts an integer sort key from a type [I] and
  /// returns a [Comparator] that compares by that sort key.
  static Comparator<I> comparingByInt<I>(int Function(I) keyExtractor) {
    return comparingBy<I, num>(keyExtractor);
  }

  /// Accepts a [keyExtractor] that extracts a double sort key from a type [I] and
  /// returns a [Comparator] that compares by that sort key.
  static Comparator<I> comparingByDouble<I>(double Function(I) keyExtractor) {
    return comparingBy<I, num>(keyExtractor);
  }

  /// Accepts a [keyExtractor] that extracts a sort key from a type [I] and returns a
  /// [Comparator] that compares by that sort key using the specified [keyComparator].
  static Comparator<I> comparingByUsing<I, O>(
    O Function(I) keyExtractor,
    Comparator<O> keyComparator,
  ) {
    return _ComparingKeyUsingComparator(keyExtractor, keyComparator);
  }

  /// Returns a null-friendly comparator that considers `null` to be less than
  /// non-null.
  ///
  /// When both are `null`, they are considered equal. If both are non-null, [from]
  /// is used to determine the order. If [from] is null, then the returned
  /// comparator considers all non-null values to be equal.
  static Comparator<T?> nullsLower<T extends Object>(Comparator<T?>? from) {
    return _NullComparator(from, nullFirst: true);
  }

  /// Returns a null-friendly comparator that considers `null` to be greater
  /// than non-null.
  ///
  /// When both are `null`, they are considered equal. If both are non-null, [from]
  /// is used to determine the order. If [from] is null, then the returned
  /// comparator considers all non-null values to be equal.
  static Comparator<T?> nullsHigher<T extends Object>(Comparator<T?>? from) {
    return _NullComparator(from, nullFirst: false);
  }

  /// Creates a constant comparator.
  const Comparator();

  /// Compares its two arguments for order.
  ///
  /// Returns a negative integer, zero or a positive integer as the first
  /// argument is less than, equal to or greater than the second.
  int call(T o1, T o2);

  /// Returns a comparator that imposes the reverse ordering of this comparator.
  Comparator<T> reversed() => _ReversedOrderComparator(this);

  /// Returns a lexicographic-order comparator with another comparator. If this
  /// comparator considers two element equal, [other] is used to determine the
  /// order.
  Comparator<T> thenComparing(Comparator<T> other) {
    return _ThenComparingComparator(from: this, to: other);
  }

  /// Returns a lexicographic-order comparator with a [keyExtractor] that
  /// extracts a [Comparable] sort key.
  Comparator<T> thenComparingBy<R extends Comparable<R>>(
    R Function(T) keyExtractor,
  ) {
    return thenComparing(comparingBy(keyExtractor));
  }

  /// Returns a lexicographic-order comparator with a [keyExtractor] that
  /// extracts an integer sort key.
  Comparator<T> thenComparingByInt(
    int Function(T) keyExtractor,
  ) {
    return thenComparing(comparingByInt(keyExtractor));
  }

  /// Returns a lexicographic-order comparator with a [keyExtractor] that
  /// extracts a double sort key.
  Comparator<T> thenComparingByDouble(
    double Function(T) keyExtractor,
  ) {
    return thenComparing(comparingByDouble(keyExtractor));
  }

  /// Returns a lexicographic-order comparator with a [keyExtractor] that
  /// extracts a key to be compared with [keyComparator].
  Comparator<T> thenComparingByUsing<R>(
    R Function(T) keyExtractor,
    Comparator<R> keyComparator,
  ) {
    return thenComparing(comparingByUsing(keyExtractor, keyComparator));
  }
}

class _ComparingKeyUsingComparator<I, O> extends Comparator<I> {
  final O Function(I) keyExtractor;
  final Comparator<O> keyComparator;

  const _ComparingKeyUsingComparator(
    this.keyExtractor,
    this.keyComparator,
  );

  @override
  int call(I o1, I o2) => keyComparator(keyExtractor(o1), keyExtractor(o2));
}

class _ComparingKeyComparator<I, O extends Comparable<O>>
    extends Comparator<I> {
  final O Function(I) keyExtractor;

  const _ComparingKeyComparator(this.keyExtractor);

  @override
  int call(I o1, I o2) => keyExtractor(o1).compareTo(keyExtractor(o2));
}

class _ThenComparingComparator<T> extends Comparator<T> {
  final Comparator<T> from;
  final Comparator<T> to;

  const _ThenComparingComparator({required this.from, required this.to});

  @override
  int call(T o1, T o2) {
    final int res = from(o1, o2);
    return res != 0 ? res : to(o1, o2);
  }
}

class _NullComparator<T> extends Comparator<T?> {
  final bool nullFirst;
  final Comparator<T?>? real;

  const _NullComparator(this.real, {required this.nullFirst});

  @override
  int call(T? o1, T? o2) {
    final Comparator<T?>? real = this.real;
    if (o1 == null) {
      return (o2 == null) ? 0 : (nullFirst ? -1 : 1);
    }
    if (o2 == null) {
      return nullFirst ? 1 : -1;
    }
    return (real == null) ? 0 : real(o1, o2);
  }

  @override
  Comparator<T?> thenComparing(Comparator<T?> other) {
    final Comparator<T?>? real = this.real;
    return _NullComparator(
      real == null ? other : real.thenComparing(other),
      nullFirst: nullFirst,
    );
  }

  @override
  Comparator<T?> reversed() {
    final Comparator<T?>? real = this.real;
    return _NullComparator(real?.reversed(), nullFirst: !nullFirst);
  }
}

class _ComparatorFromFunction<T> extends Comparator<T> {
  final int Function(T, T) compare;

  const _ComparatorFromFunction(this.compare);

  @override
  int call(T o1, T o2) => compare(o1, o2);
}

class _ReversedOrderComparator<T> extends Comparator<T> {
  final Comparator<T> from;

  const _ReversedOrderComparator(this.from);

  @override
  int call(T o1, T o2) => from(o2, o1);

  @override
  Comparator<T> reversed() => from;
}

class _ReverseOrderComparator<T extends Comparable<T>> extends Comparator<T> {
  @override
  int call(Comparable<Object> o1, Comparable<Object> o2) {
    return o2.compareTo(o1);
  }

  @override
  Comparator<T> reversed() {
    return _NaturalOrderComparator();
  }
}

class _NaturalOrderComparator<T extends Comparable<T>> extends Comparator<T> {
  @override
  int call(Comparable<Object> o1, Comparable<Object> o2) {
    return o1.compareTo(o2);
  }

  @override
  Comparator<T> reversed() {
    return _ReverseOrderComparator();
  }
}
