import 'package:build/build.dart';
import 'package:mek_json_adapter/src/constants.dart';
import 'package:mek_json_adapter/src/generators/adapters_generator.dart';
import 'package:mek_json_adapter/src/generators/class_generator.dart';
import 'package:mek_json_adapter/src/generators/combiner_generator.dart';
import 'package:mek_json_adapter/src/generators/enum_generator.dart';
import 'package:mek_json_adapter/src/utils/dart_decorator.dart';

Builder buildAdapters(BuilderOptions options) {
  return CombinerGenerator(
    allowSyntaxErrors: true,
    buildExtensions: {
      "lib/{{}}.dart": ["lib/generated/{{}}.adapters.g.dart"]
    },
    decorator: DartDecorator(
      imports: [mekAdaptableLibrary],
    ),
    generators: [
      ClassSerializerGenerator(),
      EnumAdaptersGenerator(),
    ],
  );
}

Builder buildBundleAdapters(BuilderOptions options) {
  return BundleAdaptersGenerator(
    buildExtensions: {
      r"$lib$": [r"adapters.g.dart"],
    },
    decorator: DartDecorator(
      imports: [mekAdaptableLibrary],
    ),
  );
}

Builder buildBundleAdaptersV2(BuilderOptions options) {
  return CombinerGenerator(
    allowSyntaxErrors: true,
    decorator: DartDecorator(
      imports: [mekAdaptableLibrary],
    ),
    buildExtensions: {
      r"lib/{{}}.dart": [r"lib/{{}}.adapters_v2.g.dart"],
    },
    generators: [
      BundleAdaptersGeneratorV2(),
    ],
  );
}
