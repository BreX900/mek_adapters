import 'package:code_builder/code_builder.dart';
import 'package:mek_json_adapter/src/utils.dart';

class BuildMapperVars {
  String call(String name, Set<Reference> mappers, Set<Reference> factories) {
    Iterable buildMapper() sync* {
      for (final mapper in mappers) {
        yield '${mapper.encodeNewInstance()},';
      }
    }

    Iterable buildFactory() sync* {
      for (final factory in factories) {
        yield '${factory.encodeItemType(isConst: true)}: () => ${factory.encodeNewInstance()},';
      }
    }

    return '''final $name = Adapters(
  adapters: [${buildMapper().join()}],
  factories: {${buildFactory().join()}},
);''';
  }
}
