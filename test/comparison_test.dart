import 'dart:math';

import 'package:comparison/comparison.dart';
import 'package:comparison/src/comparison_base.dart';
import 'package:test/test.dart';

class _ComparisonMatch {
  final left = greaterThan(0);
  final none = equals(0);
  final right = lessThan(0);
}

final _ComparisonMatch higher = _ComparisonMatch();

void main() {
  group('comparison', () {
    group('integer comparison', () {
      test('default order', () {
        final Comparator<int> comparator =
            Comparator.from((o1, o2) => o1.compareTo(o2));
        expect(comparator(1, 0), higher.left);
        expect(comparator(1, 1), higher.none);
        expect(comparator(1, 2), higher.right);
      });
      test('natural order', () {
        final Comparator<num> comparator = Comparator.naturalOrder();
        expect(comparator(1, 0), higher.left);
        expect(comparator(1, 1), higher.none);
        expect(comparator(1, 2), higher.right);
      });
      test('reverse order', () {
        final Comparator<num> comparator = Comparator.reverseOrder();
        expect(comparator(1, 0), higher.right);
        expect(comparator(1, 1), higher.none);
        expect(comparator(1, 2), higher.left);
      });
      group('nulls higher', () {
        final Comparator<num?> comparator =
            Comparator.nullsHigher(Comparator.naturalOrder());
        test('without nulls', () {
          expect(comparator(1, 0), higher.left);
          expect(comparator(1, 1), higher.none);
          expect(comparator(1, 2), higher.right);
        });
        test('with nulls', () {
          expect(comparator(1, null), higher.right);
          expect(comparator(null, null), higher.none);
          expect(comparator(null, 1), higher.left);
        });
      });
      group('nulls lower', () {
        final Comparator<num?> comparator =
            Comparator.nullsLower(Comparator.naturalOrder());
        test('without nulls', () {
          expect(comparator(1, 0), higher.left);
          expect(comparator(1, 1), higher.none);
          expect(comparator(1, 2), higher.right);
        });
        test('with nulls', () {
          expect(comparator(1, null), higher.left);
          expect(comparator(null, null), higher.none);
          expect(comparator(null, 1), higher.right);
        });
      });
      test('reversed', () {
        final Comparator<num> comparator =
            Comparator.from((i0, i1) => i0.compareTo(i1));
        expect(comparator(1, 0), higher.left);
        expect(comparator(1, 1), higher.none);
        expect(comparator(1, 2), higher.right);

        final Comparator<num> reversed = comparator.reversed();
        expect(reversed(1, 0), higher.right);
        expect(reversed(1, 1), higher.none);
        expect(reversed(1, 2), higher.left);
      });
    });
    group('point comparison', () {
      group('single comparison', () {
        group('comparing key', () {
          groupPointSingleComparison(
            Comparator.comparingBy<Point<int>, num>((o) => o.x),
          );
        });
        group('comparing key using', () {
          groupPointSingleComparison(
            Comparator.comparingByUsing<Point<int>, num>(
                (o) => o.x, Comparator.from((v0, v1) => v0.compareTo(v1))),
          );
        });
      });
      group('multiple comparison', () {
        group('then comparing', () {
          groupPointMultipleComparison(
            Comparator<Point<int>>.from((o1, o2) => o1.x.compareTo(o2.x))
                .thenComparing(
                    Comparator.from((o1, o2) => o1.y.compareTo(o2.y))),
          );
        });
        group('then comparing key', () {
          groupPointMultipleComparison(
            Comparator<Point<int>>.from((o1, o2) => o1.x.compareTo(o2.x))
                .thenComparingBy<num>((o) => o.y),
          );
        });
        group('then comparing key using', () {
          groupPointMultipleComparison(
            Comparator<Point<int>>.from((o1, o2) => o1.x.compareTo(o2.x))
                .thenComparingByUsing<num>((o) => o.y,
                    Comparator<int>.from((v0, v1) => v0.compareTo(v1))),
          );
        });
      });
    });
  });
}

void groupPointSingleComparison(Comparator<Point<int>?> comparator) {
  test('second key matches', () {
    expect(comparator(Point(1, 3), Point(1, 3)), higher.none);
    expect(comparator(Point(1, 3), Point(2, 3)), higher.right);
    expect(comparator(Point(2, 3), Point(1, 3)), higher.left);
  });
  test('second key increases', () {
    expect(comparator(Point(1, 3), Point(1, 4)), higher.none);
    expect(comparator(Point(1, 3), Point(2, 4)), higher.right);
    expect(comparator(Point(2, 3), Point(1, 4)), higher.left);
  });
  test('second key decreases', () {
    expect(comparator(Point(1, 4), Point(1, 3)), higher.none);
    expect(comparator(Point(1, 4), Point(2, 3)), higher.right);
    expect(comparator(Point(2, 4), Point(1, 3)), higher.left);
  });
}

void groupPointMultipleComparison(Comparator<Point<int>?> comparator) {
  group('both keys differ', () {
    test('first key goes the opposite direction from second key', () {
      expect(comparator(Point(1, 4), Point(2, 3)), higher.right);
      expect(comparator(Point(4, 1), Point(3, 2)), higher.left);
    });
    test('first key goes the same direction as second key', () {
      expect(comparator(Point(1, 3), Point(2, 4)), higher.right);
      expect(comparator(Point(4, 2), Point(3, 1)), higher.left);
    });
  });
  test('only first key matches', () {
    expect(comparator(Point(1, 2), Point(1, 3)), higher.right);
    expect(comparator(Point(1, 3), Point(1, 2)), higher.left);
  });
  test('both keys match', () {
    expect(comparator(Point(1, 1), Point(1, 1)), higher.none);
  });
}
