import 'package:build/build.dart';
import 'package:mek_json_adapter/src/constants.dart';
import 'package:mek_json_adapter/src/generators/adapter_generator.dart';
import 'package:mek_json_adapter/src/generators/bundle_adapters_generator.dart';
import 'package:mek_json_adapter/src/generators/combiner_generator.dart';
import 'package:mek_json_adapter/src/utils/dart_decorator.dart';

Builder buildAdapters(BuilderOptions options) {
  return CombinerGenerator(
    allowSyntaxErrors: true,
    buildExtensions: {
      "lib/{{}}.dart": ["lib/generated/{{}}.adapters.dart"]
    },
    decorator: DartDecorator(
      imports: [mekAdaptableLibrary],
    ),
    generators: [
      AdapterGenerator(),
    ],
  );
}

Builder buildBundleAdapters(BuilderOptions options) {
  return CombinerGenerator(
    allowSyntaxErrors: true,
    importBuildFile: false,
    decorator: DartDecorator(
      imports: [mekAdaptableLibrary],
    ),
    buildExtensions: {
      r"lib/{{}}_adapters.dart": [r"lib/{{}}_adapters.bundle.dart"],
    },
    generators: [
      BundleAdaptersGenerator(),
    ],
  );
}
