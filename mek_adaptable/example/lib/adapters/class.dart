import 'package:mek_adaptable/mek_adaptable.dart';

class Product implements Adaptable {
  final int id;
  final String? name;
  final List<ProductTag> tags;

  const Product({
    required this.id,
    required this.name,
    required this.tags,
  });
}

enum ProductTag implements Adaptable { relevant, magi }

abstract class Pet {}

class Dog extends Pet implements Adaptable {}

class Cat extends Pet implements Adaptable {}
