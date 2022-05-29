import 'package:mek_adaptable/src/adapters/adapters.dart';
import 'package:mek_adaptable/src/item_type.dart';

abstract class Adapter<T> {
  List<Type> get types => [T];

  Map<ItemType, AdapterFactory> get factories => const {};

  @override
  String toString([String info = '']) => '$runtimeType($types$info)';
}

abstract class PrimitiveAdapter<T> extends Adapter<T> {
  T deserialize(Adapters adapters, Object object, {ItemType? type, ItemFormat? format});

  Object serialize(Adapters adapters, T item, {ItemType? type, ItemFormat? format});
}

abstract class StructuredAdapter<T> extends Adapter<T> {
  String get wireName;

  T deserialize(Adapters adapters, Map<String, dynamic> map, {ItemType? type, ItemFormat? format});

  Map<String, dynamic> serialize(Adapters adapters, T item, {ItemType? type, ItemFormat? format});
}
