import 'package:mek_adaptable/src/adapters/adapters.dart';
import 'package:mek_adaptable/src/adapters/adapters_base.dart';
import 'package:mek_adaptable/src/item_type.dart';

class ItemFormatNotSupportedError {
  final Adapter recipe;
  final Object data;
  final ItemType? type;
  final ItemFormat? format;

  ItemFormatNotSupportedError(this.recipe, this.data, this.type, this.format);

  @override
  String toString() =>
      'The type-format ($type-$format) is not supported in this recipe: $recipe\n$data';
}

class BoolAdapter extends PrimitiveAdapter<bool> {
  @override
  bool deserialize(Adapters adapters, Object object, {ItemType? type, ItemFormat? format}) {
    switch (format) {
      case ItemFormat.bool:
        break;
      case null:
      case ItemFormat.int:
      case ItemFormat.double:
      case ItemFormat.num:
        object = object == 1;
        break;
      case ItemFormat.string:
        object = object == 'true';
        break;
      default:
        throw ItemFormatNotSupportedError(this, object, type, format);
    }
    return object as bool;
  }

  @override
  Object serialize(Adapters adapters, bool item, {ItemType? type, ItemFormat? format}) {
    switch (format) {
      case ItemFormat.bool:
        return item;
      case null:
      case ItemFormat.int:
        return item ? 1 : 0;
      case ItemFormat.double:
      case ItemFormat.num:
        return item ? 1.0 : 0.0;
      case ItemFormat.string:
        return item ? 'true' : 'false';
      default:
        throw ItemFormatNotSupportedError(this, item, type, format);
    }
  }
}

class NumberAdapter extends PrimitiveAdapter<num> {
  @override
  num deserialize(Adapters adapters, Object object, {ItemType? type, ItemFormat? format}) {
    switch (format) {
      case ItemFormat.bool:
        object = (object as bool) ? 1 : 0;
        break;
      case null:
      case ItemFormat.int:
      case ItemFormat.double:
      case ItemFormat.num:
        break;
      case ItemFormat.string:
        object = num.parse(object as String);
        break;
      default:
        throw ItemFormatNotSupportedError(this, object, type, format);
    }
    return object as num;
  }

  @override
  Object serialize(Adapters adapters, num item, {ItemType? type, ItemFormat? format}) {
    switch (format) {
      case ItemFormat.bool:
        return item != 0;
      case null:
      case ItemFormat.int:
      case ItemFormat.double:
      case ItemFormat.num:
        return item;
      case ItemFormat.string:
        return item.toString();
      default:
        throw ItemFormatNotSupportedError(this, item, type, format);
    }
  }
}

class IntegerAdapter extends PrimitiveAdapter<int> {
  @override
  int deserialize(Adapters adapters, Object object, {ItemType? type, ItemFormat? format}) {
    switch (format) {
      case ItemFormat.bool:
        object = (object as bool) ? 1 : 0;
        break;
      case null:
      case ItemFormat.int:
      case ItemFormat.double:
      case ItemFormat.num:
        break;
      case ItemFormat.string:
        object = int.parse(object as String);
        break;
      default:
        throw ItemFormatNotSupportedError(this, object, type, format);
    }
    return object as int;
  }

  @override
  Object serialize(Adapters adapters, int item, {ItemType? type, ItemFormat? format}) {
    switch (format) {
      case ItemFormat.bool:
        return item != 0;
      case null:
      case ItemFormat.int:
      case ItemFormat.double:
      case ItemFormat.num:
        return item;
      case ItemFormat.string:
        return item.toString();
      default:
        throw ItemFormatNotSupportedError(this, item, type, format);
    }
  }
}

class DoubleAdapter extends PrimitiveAdapter<double> {
  @override
  double deserialize(Adapters adapters, Object object, {ItemType? type, ItemFormat? format}) {
    switch (format) {
      case ItemFormat.bool:
        object = (object as bool) ? 1.0 : 0.0;
        break;
      case null:
      case ItemFormat.int:
      case ItemFormat.double:
      case ItemFormat.num:
        break;
      case ItemFormat.string:
        object = double.parse(object as String);
        break;
      default:
        throw ItemFormatNotSupportedError(this, object, type, format);
    }
    return object as double;
  }

  @override
  Object serialize(Adapters adapters, double item, {ItemType? type, ItemFormat? format}) {
    switch (format) {
      case ItemFormat.bool:
        return item != 0;
      case null:
      case ItemFormat.int:
      case ItemFormat.double:
      case ItemFormat.num:
        return item;
      case ItemFormat.string:
        return item.toString();
      default:
        throw ItemFormatNotSupportedError(this, item, type, format);
    }
  }
}

class StringAdapter extends PrimitiveAdapter<String> {
  @override
  String deserialize(Adapters adapters, Object object, {ItemType? type, ItemFormat? format}) {
    switch (format) {
      case null:
      case ItemFormat.string:
        return object as String;
      default:
        throw ItemFormatNotSupportedError(this, object, type, format);
    }
  }

  @override
  Object serialize(Adapters adapters, String item, {ItemType? type, ItemFormat? format}) {
    switch (format) {
      case null:
      case ItemFormat.string:
        return item;
      default:
        throw ItemFormatNotSupportedError(this, item, type, format);
    }
  }
}

class DateTimeAdapter extends PrimitiveAdapter<DateTime> {
  final ItemFormat defaultFormat;

  DateTimeAdapter({
    this.defaultFormat = ItemFormat.dateTimeMillisecondsSinceEpoch,
  });

  @override
  DateTime deserialize(Adapters adapters, Object object, {ItemType? type, ItemFormat? format}) {
    switch (format ?? defaultFormat) {
      case ItemFormat.dateTimeMillisecondsSinceEpoch:
        return DateTime.fromMillisecondsSinceEpoch(object as int);
      case ItemFormat.dateTimeIso8601String:
        return DateTime.parse(object as String);
      default:
        throw ItemFormatNotSupportedError(this, object, type, format);
    }
  }

  @override
  Object serialize(Adapters adapters, DateTime item, {ItemType? type, ItemFormat? format}) {
    switch (format ?? defaultFormat) {
      case ItemFormat.dateTimeMillisecondsSinceEpoch:
        return item.millisecondsSinceEpoch;
      case ItemFormat.dateTimeIso8601String:
        return item.toIso8601String();
      default:
        throw ItemFormatNotSupportedError(this, item, type, format);
    }
  }

  @override
  String toString([String info = '']) => super.toString(', $defaultFormat$info');
}
