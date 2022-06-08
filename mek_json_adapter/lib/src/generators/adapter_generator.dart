import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:mek_adaptable/mek_adaptable.dart';
import 'package:mek_json_adapter/src/builders/build_adapter_class.dart';
import 'package:mek_json_adapter/src/generators/combiner_generator.dart';
import 'package:mek_json_adapter/src/utils.dart';
import 'package:mek_json_adapter/src/utils/field_helpers.dart';
import 'package:mek_json_adapter/src/utils/reference_type_visitor.dart';

class AdapterGenerator extends SuperTypeGenerator<Adaptable>
    with ClassAdapterGenerator, EnumAdapterGenerator {
  const AdapterGenerator();

  @override
  Library? generateForExtendedElement(
    ClassElement element,
    BuildStep buildStep,
  ) {
    if (element.isEnum) {
      return generateEnumAdapter(element, buildStep);
    } else if (!element.isAbstract && !element.isMixin) {
      return generateClassAdapter(element, buildStep);
    }
    return null;
  }
}

mixin ClassAdapterGenerator {
  Library? generateClassAdapter(ClassElement element, BuildStep buildStep) {
    final codecs = Codecs();
    final buildDataMapperClass = BuildDataMapperClass(
      codecs: codecs,
    );

    final targetType = element.thisType;

    final fields = createSortedFieldSet(element).where((field) {
      if (field.isStatic || !field.isFinal) return false;
      if (field.isPrivate || field.hasInitializer) return false;
      return true;
    }).map((element) {
      return FieldSchema(
        type: element.type.accept(ReferenceTypeVisitor()),
        format: null,
        required: element.type.nullabilitySuffix != NullabilitySuffix.question,
        nullable: false,
        name: element.name,
        key: element.name,
      );
    }).toList();

    final serializerClass = buildDataMapperClass(
      classSchema: ClassSchema(
        type: targetType.accept(ReferenceTypeVisitor()),
        isPrivate: false,
      ),
      fieldSchemas: fields,
    );

    return Library((b) => b
      ..directives.addAll(fields
          // .where((field) => !field.type.url!.startsWith('dart:'))
          // .toSet()
          .map((field) => Directive.import(field.type.url!)))
      ..body.add(serializerClass.class$));
  }
}

mixin EnumAdapterGenerator {
  Library? generateEnumAdapter(ClassElement element, BuildStep buildStep) {
    final codecs = Codecs();
    final buildEnumMapperClass = BuildEnumMapperClass(
      codecs: codecs,
    );

    final targetType = element.thisType;
    final fields = iterateEnumFields(targetType)!;

    final enumName = targetType.getDisplayString(withNullability: false);

    final serializerClass = buildEnumMapperClass(
      classSchema: EnumSchema(
        isPrivate: false,
        name: enumName,
      ),
      entrySchemas: fields.map((field) {
        return EnumEntrySchema(
          name: codecs.encodeEnumValue(field.name),
          value: field.name,
        );
      }).toList(),
    );

    return Library((b) => b..body.add(serializerClass.class$));
  }

  Iterable<FieldElement>? iterateEnumFields(DartType targetType) {
    if (targetType is InterfaceType && targetType.element.isEnum) {
      return targetType.element.fields.where((element) => !element.isSynthetic);
    }
    return null;
  }
}
