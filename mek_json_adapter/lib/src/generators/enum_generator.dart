import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:mek_adaptable/mek_adaptable.dart';
import 'package:mek_json_adapter/src/builders/build_adapter_class.dart';
import 'package:mek_json_adapter/src/generators/combiner_generator.dart';
import 'package:mek_json_adapter/src/utils.dart';
import 'package:source_gen/source_gen.dart';

class EnumAdaptersGenerator extends AnnotationGenerator<AdaptableEnum> {
  const EnumAdaptersGenerator();

  @override
  Library? generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement || !element.isEnum) {
      return null;
    }

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
