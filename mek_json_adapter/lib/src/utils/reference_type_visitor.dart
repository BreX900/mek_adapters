import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:code_builder/code_builder.dart';

class ReferenceTypeVisitor extends TypeVisitor<Reference> {
  const ReferenceTypeVisitor();

  @override
  Reference visitDynamicType(DynamicType type) => const Reference('dynamic');

  @override
  Reference visitFunctionType(type) => const Reference('dynamic');

  @override
  Reference visitInterfaceType(InterfaceType type) {
    return TypeReference((b) => b
      ..url = type.element.library.identifier
      ..symbol = type.element.name
      ..types.addAll(type.typeArguments.map((e) => e.accept(this))));
  }

  @override
  Reference visitNeverType(NeverType type) => const Reference('Never');

  @override
  Reference visitTypeParameterType(TypeParameterType type) => Reference(type.element.name);

  @override
  Reference visitVoidType(VoidType type) => const Reference('void');
}
