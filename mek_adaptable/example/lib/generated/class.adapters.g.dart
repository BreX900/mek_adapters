// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:mek_adaptable/mek_adaptable.dart';
import 'package:example/class.dart';

class ProductAdapter extends StructuredAdapter<Product> {
  @override
  String get wireName => 'Product';
  @override
  Product deserialize(Adapters adapters, Map<String, dynamic> map,
      {ItemType? type, ItemFormat? format}) {
    return Product(
      id: adapters.deserialize(map['id'], type: const ItemType(int)),
      name: adapters.deserialize(map['name'], type: const ItemType(String)),
      tags: adapters.deserialize(map['tags'],
          type: const ItemType(List, [ItemType(ProductTag)])),
    );
  }

  @override
  Map<String, dynamic> serialize(Adapters adapters, Product item,
      {ItemType? type, ItemFormat? format}) {
    return <String, dynamic>{
      'id': adapters.serialize(item.id, type: const ItemType(int)),
      if (item.name != null)
        'name': adapters.serialize(item.name, type: const ItemType(String)),
      'tags': adapters.serialize(item.tags,
          type: const ItemType(List, [ItemType(ProductTag)])),
    };
  }

  @override
  Map<ItemType, Factory> get factories => {
        const ItemType(List, [ItemType(ProductTag)]): () => <ProductTag>[],
      };
}

class DogAdapter extends StructuredAdapter<Dog> {
  @override
  String get wireName => 'Dog';
  @override
  Dog deserialize(Adapters adapters, Map<String, dynamic> map,
      {ItemType? type, ItemFormat? format}) {
    return Dog();
  }

  @override
  Map<String, dynamic> serialize(Adapters adapters, Dog item,
      {ItemType? type, ItemFormat? format}) {
    return <String, dynamic>{};
  }
}

class CatAdapter extends StructuredAdapter<Cat> {
  @override
  String get wireName => 'Cat';
  @override
  Cat deserialize(Adapters adapters, Map<String, dynamic> map,
      {ItemType? type, ItemFormat? format}) {
    return Cat();
  }

  @override
  Map<String, dynamic> serialize(Adapters adapters, Cat item,
      {ItemType? type, ItemFormat? format}) {
    return <String, dynamic>{};
  }
}

class ProductTagAdapter extends PrimitiveAdapter<ProductTag> {
  @override
  ProductTag deserialize(Adapters adapters, Object object,
      {ItemType? type, ItemFormat? format}) {
    return const {
      'relevant': ProductTag.relevant,
      'magi': ProductTag.magi,
    }[object]!;
  }

  @override
  Object serialize(Adapters adapters, ProductTag item,
      {ItemType? type, ItemFormat? format}) {
    return const {
      ProductTag.relevant: 'relevant',
      ProductTag.magi: 'magi',
    }[item]!;
  }
}
