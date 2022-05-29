import 'package:collection/collection.dart';
import 'package:mek_adaptable/src/adapters/adapters_base.dart';
import 'package:mek_adaptable/src/adapters/collections_adapters.dart';
import 'package:mek_adaptable/src/adapters/primitives_adapters.dart';
import 'package:mek_adaptable/src/item_type.dart';

typedef AdapterFactory = Object Function();

class Adapters {
  final String discriminator;
  final List<AdapterPlugin> _plugins;
  final Map<Type, Adapter> _adapters;
  final Map<ItemType, AdapterFactory> _factories;

  Adapters({
    this.discriminator = '\$',
    List<AdapterPlugin> plugins = const [],
    List<Adapter> adapters = const [],
    Map<ItemType, AdapterFactory> factories = const {},
  })  : _plugins = plugins,
        _adapters = {
          for (final mapper in <Adapter>[
            BoolAdapter(),
            NumberAdapter(),
            IntegerAdapter(),
            DoubleAdapter(),
            StringAdapter(),
            DateTimeAdapter(),
            ListAdapter(),
            MapAdapter(),
            ...adapters,
          ]) ...{
            for (final type in mapper.types) type: mapper,
          }
        },
        _factories = {
          ...factories,
          for (final adapter in adapters) ...adapter.factories,
        };

  Adapters._(this.discriminator, this._plugins, this._adapters, this._factories);

  // T deserializeWith<T>(Adapter<T> mapper, Object data) {
  //   if (mapper is PrimitiveAdapter<T>) {
  //     return mapper.deserialize(this, data);
  //   } else if (mapper is StructuredAdapter<T>) {
  //     return mapper.deserialize(this, data as Map<String, dynamic>);
  //   }
  //   throw 'Not supported';
  // }
  //
  // Object serializeWith<T>(Adapter<T> mapper, T data) {
  //   if (mapper is PrimitiveAdapter<T>) {
  //     return mapper.serialize(this, data);
  //   } else if (mapper is StructuredAdapter<T>) {
  //     return mapper.serialize(this, data);
  //   }
  //   throw 'Not supported';
  // }

  T deserialize<T>(
    Object? data, {
    ItemType? type,
    ItemFormat? format,
  }) {
    Adapter? recipe;
    try {
      if (data == null) return null as T;

      recipe = findMapperByItemType(type) ?? findMapperByWireName(data);

      if (recipe is PrimitiveAdapter) {
        return recipe.deserialize(this, data, type: type, format: format) as T;
      } else if (recipe is StructuredAdapter) {
        data as Map<String, dynamic>;
        return recipe.deserialize(this, data, type: type, format: format) as T;
      } else {
        throw UnknownAdapterError(data, type, format);
      }
    } on AdaptError {
      rethrow;
    } catch (error, stackTrace) {
      throw AdaptError(recipe, data, type, format, error, stackTrace);
    }
  }

  Object? serialize<T>(
    T data, {
    ItemType? type,
    ItemFormat? format,
  }) {
    if (data == null) return null;

    final mapper = findMapperByItemType(type) ?? findMapperByRuntimeType(data);

    Object? serialized;
    try {
      if (mapper is PrimitiveAdapter) {
        serialized = mapper.serialize(this, data, type: type, format: format);
      } else if (mapper is StructuredAdapter) {
        serialized = {
          if (type == null) discriminator: mapper.wireName,
          ...mapper.serialize(this, data, type: type, format: format),
        };
      } else {
        throw UnknownAdapterError(data, type, format);
      }
    } on AdaptError {
      rethrow;
    } catch (error, stackTrace) {
      throw AdaptError(mapper, data, type, format, error, stackTrace);
    }

    return _plugins.fold(serialized, (object, plugin) => plugin.afterSerialize(object!, type));
  }

  T findFactory<T>(ItemType forType) {
    return _factories[forType]!() as T;
  }

  Adapter? findMapperByItemType(ItemType? type) {
    if (type == null) return null;
    return _adapters[type.root];
  }

  Adapter? findMapperByRuntimeType(Object object) {
    return findMapperByItemType(ItemType(object.runtimeType));
  }

  Adapter? findMapperByWireName(Object serialized) {
    if (serialized is! Map<String, dynamic>) return null;
    final wireName = serialized[discriminator];
    if (wireName == null) return null;
    return _adapters.values.firstWhereOrNull((element) {
      return element is StructuredAdapter ? element.wireName == wireName : false;
    });
  }

  Adapters change(void Function(AdaptersChanges c) updates) {
    final c = AdaptersChanges._(discriminator, [..._plugins], {..._adapters}, {..._factories});
    updates(c);
    return Adapters._(c.discriminator, c._plugins, c._recipes, c._factories);
  }

  @override
  String toString() => 'Adapters(\n'
      '  discriminator: $discriminator\n'
      '  plugins: $_plugins,\n'
      '  recipes: $_adapters,\n'
      '  factories: $_factories\n'
      ')';
}

abstract class AdapterPlugin {
  const AdapterPlugin();

  Object afterSerialize(Object object, ItemType? type) => object;
}

class AdaptError {
  final Adapter? recipe;
  final Object? data;
  final ItemType? type;
  final ItemFormat? format;
  final Object error;
  final StackTrace stackTrace;

  AdaptError(this.recipe, this.data, this.type, this.format, this.error, this.stackTrace);

  @override
  String toString() => 'Failed use a $recipe for $type-$format\n'
      'Data: $data\n'
      'OriginalError: $error\n'
      'OriginalStackTrace: $stackTrace';
}

class UnknownAdapterError {
  final Object? data;
  final ItemType? type;
  final ItemFormat? format;

  const UnknownAdapterError(this.data, this.type, this.format);

  @override
  String toString() => 'Not know adapter for $type-$format'
      '\nData: $data';
}

class AdaptersChanges {
  String discriminator;
  final List<AdapterPlugin> _plugins;
  final Map<Type, Adapter> _recipes;
  final Map<ItemType, AdapterFactory> _factories;

  AdaptersChanges._(this.discriminator, this._plugins, this._recipes, this._factories);

  void addAllPlugins(Iterable<AdapterPlugin> plugins) => _plugins.addAll(plugins);

  void addAllAdapters(Iterable<Adapter> adapters) {
    for (final adapter in adapters) {
      for (final type in adapter.types) {
        _recipes[type] = adapter;
      }
    }
  }

  void addAllFactories(Map<ItemType, AdapterFactory> factories) => _factories.addAll(factories);
}
