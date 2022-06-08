// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:mek_adaptable/mek_adaptable.dart';
import 'package:example/enum.dart';

class ProductNameAdapter extends PrimitiveAdapter<ProductName> {
  @override
  ProductName deserialize(Adapters adapters, Object object,
      {ItemType? type, ItemFormat? format}) {
    return const {
      'paper': ProductName.paper,
      'book': ProductName.book,
    }[object]!;
  }

  @override
  Object serialize(Adapters adapters, ProductName item,
      {ItemType? type, ItemFormat? format}) {
    return const {
      ProductName.paper: 'paper',
      ProductName.book: 'book',
    }[item]!;
  }
}
