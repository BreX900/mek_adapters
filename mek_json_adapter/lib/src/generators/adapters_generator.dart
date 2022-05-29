import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:glob/glob.dart';
import 'package:mek_adaptable/mek_adaptable.dart';
import 'package:mek_json_adapter/src/builders/build_adapets_var.dart';
import 'package:mek_json_adapter/src/utils/dart_decorator.dart';
import 'package:source_gen/source_gen.dart';

class BundleAdaptersGenerator implements Builder {
  @override
  final Map<String, List<String>> buildExtensions;
  final DartDecorator decorator;

  const BundleAdaptersGenerator({
    required this.buildExtensions,
    required this.decorator,
  });

  static final _allAdaptersFiles = Glob('**.adapters.g.dart');

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final buildAdaptersVar = BuildMapperVars();

    final files = await buildStep.findAssets(_allAdaptersFiles).toList();

    final elements = await Future.wait(files.map<Future<Iterable<ClassElement>>>((input) async {
      if (!await buildStep.resolver.isLibrary(input)) return const [];

      final library = await buildStep.resolver.libraryFor(input);
      final reader = LibraryReader(library);

      return reader.classes.where(TypeChecker.fromRuntime(Adapter).isSuperOf);
    }));

    final classes = elements.expand((element) => element);

    final imports = classes.map((e) => e.library.identifier);

    final content = buildAdaptersVar('adapters', classes.map((e) => Reference(e.name)).toSet(), {});

    final code = decorator.decorate(
      imports: imports,
      code: content,
    );

    await buildStep.writeAsString(
      buildStep.allowedOutputs.single,
      code,
    );
  }
}

class BundleAdaptersGeneratorV2 implements Builder {
  @override
  final Map<String, List<String>> buildExtensions;
  final DartDecorator decorator;

  const BundleAdaptersGeneratorV2({
    required this.buildExtensions,
    required this.decorator,
  });

  static final _allAdaptersFiles = Glob('**.adapters.g.dart');

  TypeChecker get typeChecker => TypeChecker.fromRuntime(BundleAdapters);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final libraryElement = await buildStep.resolver.libraryFor(buildStep.inputId);

    final libraryReader = LibraryReader(libraryElement);

    for (var annotatedElement in libraryReader.annotatedWith(typeChecker)) {
      final buildAdaptersVar = BuildMapperVars();

      final files = await buildStep.findAssets(_allAdaptersFiles).toList();

      final elements = await Future.wait(files.map<Future<Iterable<ClassElement>>>((input) async {
        if (!await buildStep.resolver.isLibrary(input)) return const [];

        final library = await buildStep.resolver.libraryFor(input);
        final reader = LibraryReader(library);

        return reader.classes.where(TypeChecker.fromRuntime(Adapter).isSuperOf);
      }));

      final classes = elements.expand((element) => element);

      final imports = classes.map((e) => e.library.identifier);

      final content =
          buildAdaptersVar('adapters', classes.map((e) => Reference(e.name)).toSet(), {});

      final code = decorator.decorate(
        imports: imports,
        code: content,
      );

      await buildStep.writeAsString(
        buildStep.allowedOutputs.single,
        code,
      );
    }
  }
}
