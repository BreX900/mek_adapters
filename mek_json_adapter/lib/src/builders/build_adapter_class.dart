import 'package:code_builder/code_builder.dart';
import 'package:mek_adaptable/mek_adaptable.dart';
import 'package:mek_json_adapter/src/utils.dart';

class _RecipeBookClassRefs {
  const _RecipeBookClassRefs();

  final String deserialize = '${_RecipeClassRefs._adapters}.deserializeAny';
  final String serialize = '${_RecipeClassRefs._adapters}.serializeAny';

  static const String _deserialize = 'deserialize';
  static const String _serialize = 'serialize';

  @override
  String toString() => _RecipeClassRefs._adapters;
}

class _RecipeClassRefs {
  final _RecipeBookClassRefs book = const _RecipeBookClassRefs();
  final String data;
  final String type = _type;
  final String format = _format;

  _RecipeClassRefs(this.data);

  static const String _adapters = 'adapters';
  static const String _item = 'item';
  static const String _object = 'object';
  static const String _map = 'map';
  static const String _type = 'type';
  static const String _format = 'format';
}

Class _buildRecipeClass({
  required bool isPrivate,
  required bool isPrimitive,
  required Reference classRef,
  required String Function(_RecipeClassRefs refs) craftEncoder,
  required String Function(_RecipeClassRefs refs) smashEncoder,
}) {
  final mapperRef = Reference('${isPrivate ? '_' : ''}${classRef.symbol}Adapter');
  final rawDataName = isPrimitive ? _RecipeClassRefs._object : _RecipeClassRefs._map;

  final bookParam = Parameter((b) => b
    ..type = jsonMappersRef
    ..name = _RecipeClassRefs._adapters);
  final optionalParams = [
    Parameter((b) => b
      ..named = true
      ..type = jsonTypeRef.toNull()
      ..name = _RecipeClassRefs._type),
    Parameter((b) => b
      ..named = true
      ..type = jsonFormatRef.toNull()
      ..name = _RecipeClassRefs._format)
  ];

  return Class((b) => b
    ..name = mapperRef.symbol
    ..types.replace(classRef.types)
    ..extend = TypeReference((b) => b
      ..symbol = '${isPrimitive ? 'Primitive' : 'Structured'}Adapter'
      ..types.add(classRef))
    ..methods.addAll([
      if (!isPrimitive)
        Method((b) => b
          ..annotations.add(overrideAnnotation)
          ..returns = const Reference('String')
          ..type = MethodType.getter
          ..name = 'wireName'
          ..lambda = true
          ..body = literalString(classRef.symbol!).code),
    ])
    ..methods.add(Method((b) => b
      ..annotations.add(overrideAnnotation)
      ..returns = classRef
      ..name = _RecipeBookClassRefs._deserialize
      ..requiredParameters.addAll([
        bookParam,
        Parameter((b) => b
          ..type = isPrimitive ? jsonObjectRef : jsonMapRef
          ..name = rawDataName),
      ])
      ..optionalParameters.addAll(optionalParams)
      ..lambda = false
      ..body = Code(craftEncoder(_RecipeClassRefs(rawDataName)))))
    ..methods.add(Method((b) => b
      ..annotations.add(overrideAnnotation)
      ..returns = isPrimitive ? jsonObjectRef : jsonMapRef
      ..name = _RecipeBookClassRefs._serialize
      ..requiredParameters.addAll([
        bookParam,
        Parameter((b) => b
          ..type = classRef
          ..name = _RecipeClassRefs._item),
      ])
      ..optionalParameters.addAll(optionalParams)
      ..lambda = false
      ..body = Code(smashEncoder(_RecipeClassRefs(_RecipeClassRefs._item))))));
}

class BuildDataMapperClass {
  final Codecs codecs;

  const BuildDataMapperClass({
    required this.codecs,
  });

  BuiltMapper call({
    required ClassSchema classSchema,
    required List<FieldSchema> fieldSchemas,
  }) {
    var class$ = _buildRecipeClass(
      isPrivate: classSchema.isPrivate,
      isPrimitive: false,
      classRef: classSchema.type,
      craftEncoder: (refs) => 'return ${classSchema.type.symbol}('
          '${fieldSchemas.map((field) {
        return "${field.name}: ${refs.book.deserialize}(${refs.data}['${field.key}'], ${refs.type}: ${field.type.encodeItemType(isConst: true)}),";
      }).join()}'
          ');',
      smashEncoder: (refs) => 'return <String, dynamic>{'
          '${fieldSchemas.map((field) {
        print(field.type.url);
        final code =
            "'${field.key}': ${refs.book.serialize}(${refs.data}.${field.name}, ${refs.type}: ${field.type.encodeItemType(isConst: true)}),";

        if (!field.required) {
          return 'if (item.${field.name} != null) $code';
        }

        return code;
      }).join('\n')}'
          '};',
    );

    final factories = fieldSchemas.map((e) => e.type).where((e) => e.types.isNotEmpty).toSet();
    if (factories.isNotEmpty) {
      class$ = class$.rebuild((b) => b
        ..methods.add(Method((b) => b
          ..annotations.add(overrideAnnotation)
          ..returns = Reference('Map<ItemType, Factory>')
          ..type = MethodType.getter
          ..name = 'factories'
          ..lambda = true
          ..body = Code('{${buildFactory(factories).join(', ')}}'))));
    }

    return BuiltMapper(
      class$: class$,
      factories: factories,
    );
  }
}

Iterable buildFactory(Set<Reference> factories) sync* {
  for (final factory in factories) {
    yield '${factory.encodeItemType(isConst: true)}: () => ${factory.encodeNewInstance()},';
  }
}

class BuildEnumMapperClass {
  final Codecs codecs;

  const BuildEnumMapperClass({
    required this.codecs,
  });

  BuiltMapper call({
    required EnumSchema classSchema,
    required List<EnumEntrySchema> entrySchemas,
  }) {
    return BuiltMapper(
      class$: _buildRecipeClass(
        isPrivate: classSchema.isPrivate,
        isPrimitive: true,
        classRef: Reference(classSchema.name),
        craftEncoder: (refs) => 'return const {'
            '${entrySchemas.map((entry) {
          return "${codecs.encodeDartValue(entry.value)}: ${classSchema.name}.${entry.name},";
        }).join()}'
            '}[${refs.data}]!;',
        smashEncoder: (refs) => 'return const {'
            '${entrySchemas.map((entry) {
          return "${classSchema.name}.${entry.name}: ${codecs.encodeDartValue(entry.value)},";
        }).join()}'
            '}[${refs.data}]!;',
      ),
      factories: const {},
    );
  }
}

class ClassSchema {
  final bool isPrivate;
  final Reference type;

  const ClassSchema({
    required this.isPrivate,
    required this.type,
  });
}

class FieldSchema {
  final Reference type;
  final ItemFormat? format;

  /// If not required and value is `null`, it is not written in json
  final bool required;

  /// Determine the value can null
  final bool nullable;
  final String name;
  final String key;

  const FieldSchema({
    required this.type,
    required this.format,
    required this.required,
    required this.nullable,
    required this.name,
    required this.key,
  });
}

class EnumSchema {
  final bool isPrivate;
  final String name;

  const EnumSchema({
    required this.isPrivate,
    required this.name,
  });
}

class EnumEntrySchema {
  final String name;
  final Object value;

  const EnumEntrySchema({
    required this.name,
    required this.value,
  });
}

class BuiltMapper {
  final Class class$;
  final Set<Reference> factories;

  const BuiltMapper({
    required this.class$,
    required this.factories,
  });
}
