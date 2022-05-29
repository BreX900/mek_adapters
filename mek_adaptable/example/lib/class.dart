import 'package:mek_adaptable/mek_adaptable.dart';

@AdaptableClass()
class Product {
  final int id;
  final String? name;
  final List<ProductTag> tags;

  const Product({
    required this.id,
    required this.name,
    required this.tags,
  });
}

@AdaptableEnum()
enum ProductTag { relevant, magi }

abstract class Pet {}

@AdaptableClass()
class Dog extends Pet {}

@AdaptableClass()
class Cat extends Pet {}
