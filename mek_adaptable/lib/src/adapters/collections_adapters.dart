import 'package:mek_adaptable/src/adapters/adapters.dart';
import 'package:mek_adaptable/src/adapters/adapters_base.dart';
import 'package:mek_adaptable/src/item_type.dart';

class ListAdapter extends PrimitiveAdapter<List> {
  @override
  List deserialize(Adapters adapters, Object object, {ItemType? type, ItemFormat? format}) {
    final list = adapters.findFactory<List>(type!);

    for (final e in (object as List)) {
      list.add(adapters.deserialize(e, type: type.params.single));
    }

    return list;
  }

  @override
  Object serialize(Adapters adapters, List item, {ItemType? type, ItemFormat? format}) {
    return item.map((e) {
      return adapters.serializeAny(e, type: type!.params.single);
    }).toList();
  }
}

class MapAdapter extends PrimitiveAdapter<Map> {
  @override
  Map deserialize(Adapters adapters, Object object, {ItemType? type, ItemFormat? format}) {
    final keyType = type!.params.first;
    final valueType = type.params.last;

    final map = adapters.findFactory<Map>(type);

    (object as Map).forEach((key, value) {
      map[adapters.serializeAny(key, type: keyType)] = adapters.deserialize(value, type: valueType);
    });

    return map;
  }

  @override
  Object serialize(Adapters adapters, Map item, {ItemType? type, ItemFormat? format}) {
    final keyType = type!.params.first;
    final valueType = type.params.last;

    return item.map((key, value) {
      return MapEntry(
        adapters.serializeAny(key, type: keyType),
        adapters.serializeAny(value, type: valueType),
      );
    });
  }
}
