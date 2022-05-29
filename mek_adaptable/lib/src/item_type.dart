import 'package:collection/collection.dart';

class ItemType {
  final Type root;
  final List<ItemType> params;

  const ItemType(this.root, [this.params = const []]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemType &&
          runtimeType == other.runtimeType &&
          root == other.root &&
          const ListEquality().equals(params, other.params);
  @override
  int get hashCode => Object.hash(root, params);

  @override
  String toString() => 'ItemType($root${params.isEmpty ? '' : '$params'})';
}

enum ItemFormat {
  bool,
  int,
  double,
  num,
  string,
  list,
  map,
  dateTimeIso8601String,
  dateTimeMillisecondsSinceEpoch
}
