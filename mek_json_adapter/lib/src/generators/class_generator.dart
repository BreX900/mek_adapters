// import 'package:analyzer/dart/element/element.dart';
// import 'package:analyzer/dart/element/nullability_suffix.dart';
// import 'package:analyzer/dart/element/type.dart';
// import 'package:build/build.dart';
// import 'package:code_builder/code_builder.dart';
// import 'package:mek_adaptable/mek_adaptable.dart';
// import 'package:mek_json_adapter/src/builders/build_adapter_class.dart';
// import 'package:mek_json_adapter/src/generators/combiner_generator.dart';
// import 'package:mek_json_adapter/src/utils.dart';
// import 'package:mek_json_adapter/src/utils/field_helpers.dart';
// import 'package:mek_json_adapter/src/utils/reference_type_visitor.dart';
// import 'package:source_gen/source_gen.dart';
//
// class ClassSerializerGenerator extends AnnotationGenerator<AdaptableClass> {
//   const ClassSerializerGenerator();
//
//   @override
//   Library? generateForAnnotatedElement(
//     Element element,
//     ConstantReader annotation,
//     BuildStep buildStep,
//   ) {
//     if (element is! ClassElement || element.isAbstract || element.isEnum || element.isMixin) {
//       return null;
//     }
//
//     final codecs = Codecs();
//     final buildDataMapperClass = BuildDataMapperClass(
//       codecs: codecs,
//     );
//
//     final targetType = element.thisType;
//
//     final fields = createSortedFieldSet(element).where((field) {
//       if (field.isStatic || !field.isFinal) return false;
//       if (field.isPrivate || field.hasInitializer) return false;
//       return true;
//     }).map((element) {
//       return FieldSchema(
//         type: element.type.accept(ReferenceTypeVisitor()),
//         format: null,
//         required: element.type.nullabilitySuffix != NullabilitySuffix.question,
//         nullable: false,
//         name: element.name,
//         key: element.name,
//       );
//     }).toList();
//
//     final serializerClass = buildDataMapperClass(
//       classSchema: ClassSchema(
//         type: targetType.accept(ReferenceTypeVisitor()),
//         isPrivate: false,
//       ),
//       fieldSchemas: fields,
//     );
//
//     return Library((b) => b
//       ..directives.addAll(fields
//           // .where((field) => !field.type.url!.startsWith('dart:'))
//           // .toSet()
//           .map((field) => Directive.import(field.type.url!)))
//       ..body.add(serializerClass.class$));
//   }
//
//   Iterable<FieldElement>? iterateEnumFields(DartType targetType) {
//     if (targetType is InterfaceType && targetType.element.isEnum) {
//       return targetType.element.fields.where((element) => !element.isSynthetic);
//     }
//     return null;
//   }
// }
