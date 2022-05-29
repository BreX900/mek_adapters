import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

const jsonMappersRef = Reference('Adapters');
const jsonMapRef = Reference('Map<String, dynamic>');
const jsonObjectRef = Reference('Object');
const jsonTypeRef = Reference('ItemType');
const jsonFormatRef = Reference('ItemFormat');
const overrideAnnotation = CodeExpression(Code('override'));

extension ReferenceExtensions on Reference {
  bool get isVoid => symbol == 'void';

  bool get isNullable {
    final self = this;
    return self is TypeReference ? (self.isNullable ?? false) : false;
  }

  Iterable<Reference> get types {
    final self = this;
    return self is TypeReference ? self.types : const [];
  }

  Reference toNull([bool? nullable = true]) {
    return TypeReference((b) => b
      ..symbol = symbol
      ..types.replace(types)
      ..isNullable = nullable ?? b.isNullable);
  }

  String encodeItemType({bool isConst = false}) {
    return '${isConst ? 'const ' : ''}${jsonTypeRef.symbol}('
        '$symbol'
        '${types.isEmpty ? '' : ', [${types.map((e) => e.encodeItemType()).join(', ')}]'}'
        ')';
  }

  String encodeTypes() {
    return types.isEmpty ? '' : '<${types.map((e) => '${e.symbol}${e.encodeTypes()}').join(', ')}>';
  }

  String encodeType() {
    return '$symbol${encodeTypes()}';
  }

  static final _constructors = {'List': '[]', 'Map': '{}'};
  String encodeNewInstance({bool isConst = false}) {
    final constructor = _constructors[symbol];
    return '${isConst ? 'const ' : ''}'
        '${constructor != null ? '' : symbol}'
        '${encodeTypes()}'
        '${constructor ?? '()'}';
  }

  Expression encodeJsonTypeCode() {
    return jsonTypeRef.constInstance([
      Reference(symbol),
      if (types.isNotEmpty)
        literalList([
          for (final type in types) type.encodeJsonTypeCode(),
        ]),
    ]);
  }
}

void lg(String tag, Object message) {
  print('[$tag] $message');
}

Spec buildLine(String code) {
  return CodeExpression(Code(code)).statement;
}

class Codecs {
  const Codecs();

  @protected
  String encodeType(String name) => name;

  static final _keywords = {
    'else',
    'enum',
    'in',
    'assert',
    'super',
    'extends',
    'is',
    'switch',
    'break',
    'this',
    'case',
    'throw',
    'catch',
    'false',
    'new',
    'true',
    'class',
    'final',
    'null',
    'try',
    'const',
    'finally',
    'continue',
    'for',
    'var',
    'void',
    'default',
    'while',
    'rethrow',
    'with',
    'do',
    'if',
    'return',
  };

  @protected
  String encodeFieldName(String str) => _keywords.contains(str) ? '$str\$' : str;

  String encodeDartValue(Object value) {
    if (value is String) {
      return "'$value'";
    }
    return '$value';
  }

  String encodeEnumValue(Object value) => value is String ? encodeFieldName(value) : 'vl$value';
}

Iterable<Tuple2<I1, I2>> combine2<I1, I2>(Iterable<I1> items1, Iterable<I2> items2) sync* {
  final iterator1 = items1.iterator;
  final iterator2 = items2.iterator;

  while (iterator1.moveNext() && iterator2.moveNext()) {
    yield Tuple2(iterator1.current, iterator2.current);
  }
}

extension IterableTuple2Extension<I1, I2> on Iterable<Tuple2<I1, I2>> {
  Iterable<R> mapTuple<R>(R Function(I1 item1, I2 item2) mapper) sync* {
    for (final tuple in this) {
      yield mapper(tuple.item1, tuple.item2);
    }
  }
}
