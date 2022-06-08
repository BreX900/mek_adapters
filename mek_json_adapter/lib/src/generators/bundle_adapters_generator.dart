import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:glob/glob.dart';
import 'package:mek_adaptable/mek_adaptable.dart';
import 'package:mek_json_adapter/src/builders/build_adapets_var.dart';
import 'package:mek_json_adapter/src/generators/combiner_generator.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';
import 'package:source_gen/source_gen.dart';

class BundleAdaptersGenerator extends AnnotationGenerator<BundleAdapters> {
  const BundleAdaptersGenerator();

  static final _allAdaptersFiles = '.adapters.dart';

  @override
  FutureOr<Library?> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final folder = annotation.read('include').stringValue;
    // TODO: Support factories
    // final values = annotation.read('factories').setValue;

    final buildAdaptersVar = BuildMapperVars();

    final targetFolder = p.url.joinAll(buildStep.inputId.pathSegments
      ..removeAt(0)
      ..removeLast());

    final adaptersGlob = p.url.join('lib/generated', targetFolder, '$folder$_allAdaptersFiles');

    print('$adaptersGlob -> ${p.normalize(adaptersGlob)}');

    final classes = await buildStep
        .findAssets(Glob(p.normalize(adaptersGlob)))
        .flatMapIterable((assetId) => _findAdapters(buildStep, assetId))
        .toList();

    final imports = classes.map((e) => e.library.identifier);

    final content = buildAdaptersVar(
      '\$${element.displayName}',
      classes.map((e) => Reference(e.name)).toSet(),
      {},
    );

    return Library((b) => b
      ..directives.addAll(imports.map(Directive.import))
      ..body.add(Code(content)));
  }
}

Stream<Iterable<ClassElement>> _findAdapters(BuildStep buildStep, AssetId assetId) async* {
  if (!await buildStep.resolver.isLibrary(assetId)) return;

  final library = await buildStep.resolver.libraryFor(assetId);
  final reader = LibraryReader(library);

  yield reader.classes.where(TypeChecker.fromRuntime(Adapter).isSuperOf);
}

// class BundleAdaptersGenerator implements Builder {
//   @override
//   final Map<String, List<String>> buildExtensions;
//   final DartDecorator decorator;
//
//   const BundleAdaptersGenerator({
//     required this.buildExtensions,
//     required this.decorator,
//   });
//
//   static final _allAdaptersFiles = Glob('**.adapters.g.dart');
//
//   @override
//   FutureOr<void> build(BuildStep buildStep) async {
//     final buildAdaptersVar = BuildMapperVars();
//
//     final files = await buildStep.findAssets(_allAdaptersFiles).toList();
//
//     final elements = await Future.wait(files.map<Future<Iterable<ClassElement>>>((input) async {
//       if (!await buildStep.resolver.isLibrary(input)) return const [];
//
//       final library = await buildStep.resolver.libraryFor(input);
//       final reader = LibraryReader(library);
//
//       return reader.classes.where(TypeChecker.fromRuntime(Adapter).isSuperOf);
//     }));
//
//     final classes = elements.expand((element) => element);
//
//     final imports = classes.map((e) => e.library.identifier);
//
//     final content = buildAdaptersVar('adapters', classes.map((e) => Reference(e.name)).toSet(), {});
//
//     final code = decorator.decorate(
//       imports: imports,
//       code: content,
//     );
//
//     await buildStep.writeAsString(
//       buildStep.allowedOutputs.single,
//       code,
//     );
//   }
// }
