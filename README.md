# comparison

A package that provides default, reversed and multiple field comparison.

[![Actions](https://github.com/beet-software/comparison/actions/workflows/dart.yml/badge.svg)](https://github.com/beet-software/comparison.git)
[![Pub version](https://img.shields.io/pub/v/comparison)](https://pub.dev/packages/comparison)
[![Pub points](https://badges.bar/comparison/pub%20points)](https://pub.dev/packages/comparison/score)
[![Codecov](https://codecov.io/gh/beet-software/comparison/branch/main/graph/badge.svg?token=RIXMWO86AA)](https://codecov.io/gh/beet-software/comparison)

## Getting started

To start using this package, just run

```shell
dart pub add comparison
dart pub get
```

or, if you're using Flutter,

```shell
flutter pub add comparison
flutter pub get
```

See [`pub add` command](https://dart.dev/tools/pub/cmd/pub-add) for more information.

## Usage

This package only exports a single class, `Comparator`, which you can import as below:

```dart
import 'package:comparison/comparison.dart';

final Comparator<String> comparator = Comparator.naturalOrder();
```

You can now use it to

- compare two values:

```dart
final String name = 'John Doe';
final bool manGoesFirst = comparator(name, 'Jane Doe') > 0;
// Same as: final bool manGoesFirst = name > 'Jane Doe';
```

- provide an argument to `List#sort`:

```dart

final List<String> values = ["b", "c", "a"];
values.sort(comparator);

print(values); // [a, b, c]
```

- compare multiple fields:

```dart

final Comparator<String> reversed = comparator.reversed().thenComparingBy((v) => v.length);
```

Take a look at the API reference for more usage information. You can also go through examples in
the *example/* directory.

## Additional information

This package is heavily based on JDK's comparison API. You can take a look at
[Comparators.java](https://github.com/frohoff/jdk8u-jdk/blob/master/src/share/classes/java/util/Comparators.java),
[Comparator.java](https://github.com/frohoff/jdk8u-jdk/blob/master/src/share/classes/java/util/Comparator.java) and
[Collections.java](https://github.com/frohoff/jdk8u-jdk/blob/master/src/share/classes/java/util/Collections.java)
for the base implementation.

We're accepting contributions, so feel free to push a merge request.

You can contact us at [enzo-santos@beetsoftware.com](mailto:enzo-santos@beetsoftware.com) for any
issues or add an entry in the Issues tab in this package's GitHub repository.
