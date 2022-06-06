import 'package:comparison/comparison.dart';

class Person {
  final String name;
  final int age;

  const Person({required this.name, required this.age});

  @override
  String toString() => 'Person{name: $name, age: $age}';
}

void main() {
  const List<Person> people = [
    Person(name: "Dan", age: 4),
    Person(name: "Andi", age: 2),
    Person(name: "Bob", age: 42),
    Person(name: "Debby", age: 3),
    Person(name: "Bob", age: 72),
    Person(name: "Barry", age: 20),
    Person(name: "Cathy", age: 40),
    Person(name: "Bob", age: 40),
    Person(name: "Barry", age: 50),
  ];
  Comparator<Person> comparator =
      Comparator.comparingBy((person) => person.name);
  comparator = comparator.thenComparingByInt((person) => person.age);

  final List<Person> sortedPeople = List.of(people)..sort(comparator);
  print(sortedPeople);
  // [
  //   Person{name: Andi, age: 2},
  //   Person{name: Barry, age: 20},
  //   Person{name: Barry, age: 50},
  //   Person{name: Bob, age: 40},
  //   Person{name: Bob, age: 42},
  //   Person{name: Bob, age: 72},
  //   Person{name: Cathy, age: 40},
  //   Person{name: Dan, age: 4},
  //   Person{name: Debby, age: 3},
  // ]
}
