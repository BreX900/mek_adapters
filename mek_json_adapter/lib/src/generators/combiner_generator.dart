import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:mek_json_adapter/src/constants.dart';
import 'package:mek_json_adapter/src/utils/dart_decorator.dart';
import 'package:source_gen/source_gen.dart';

class CombinerGenerator implements Builder {
  final bool allowSyntaxErrors;
  final DartDecorator decorator;
  final List<AnnotationGenerator> generators;
  @override
  final Map<String, List<String>> buildExtensions;

  CombinerGenerator({
    this.allowSyntaxErrors = false,
    required this.buildExtensions,
    required this.decorator,
    required this.generators,
  });

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final outputId = buildStep.allowedOutputs.single;

    final library = await buildStep.resolver
        .libraryFor(buildStep.inputId, allowSyntaxErrors: allowSyntaxErrors);

    final generatedOutputs = await _generate(library, generators, buildStep).toList();

    if (generatedOutputs.isEmpty) return;

    // Directive class has show and hide fields with List type, cant resolve correct hashcode
    final directives = <String>{};
    final bodies = <Spec>[];

    for (var library in generatedOutputs) {
      directives.addAll(library.directives.map((e) => e.url).where((e) => !e.startsWith('dart:')));
      bodies.addAll(library.body);
    }
    final libraryCode = Library((b) => b
      ..directives.addAll(directives.map((e) => Directive.import(e)))
      ..body.addAll(bodies));

    final code = decorator.decorate(
      imports: [buildStep.inputId.uri.toString()],
      code: emitter.visitLibrary(libraryCode),
    );

    await buildStep.writeAsString(outputId, code);
  }

  Stream<Library> _generate(
    LibraryElement library,
    List<AnnotationGenerator> generators,
    BuildStep buildStep,
  ) async* {
    final libraryReader = LibraryReader(library);
    for (var i = 0; i < generators.length; i++) {
      final gen = generators[i];
      var msg = 'Running $gen';
      if (generators.length > 1) {
        msg = '$msg - ${i + 1} of ${generators.length}';
      }
      log.fine(msg);

      yield* gen.generate(libraryReader, buildStep);
    }
  }
}

abstract class AnnotationGenerator<T> {
  const AnnotationGenerator();

  TypeChecker get typeChecker => TypeChecker.fromRuntime(T);

  Stream<Library> generate(LibraryReader library, BuildStep buildStep) async* {
    for (var annotatedElement in library.annotatedWith(typeChecker)) {
      final generatedValue = await generateForAnnotatedElement(
        annotatedElement.element,
        annotatedElement.annotation,
        buildStep,
      );

      if (generatedValue != null) yield generatedValue;
    }
  }

  FutureOr<Library?> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  );
}

// class GeneratedLibrary {
//   final List<String> imports;
//   final String content;
//
//   const GeneratedLibrary({
//     this.imports = const [],
//     required this.content,
//   });
// }
