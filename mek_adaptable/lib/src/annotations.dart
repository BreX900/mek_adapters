import 'package:meta/meta_meta.dart';

abstract class Adaptable {}

@TargetKind.classType
class AdaptableClass {
  const AdaptableClass();
}

@TargetKind.enumType
class AdaptableEnum {
  const AdaptableEnum();
}

@TargetKind.topLevelVariable
class BundleAdapters {
  /// [Glob] Already filter only `.adapters.g.dart` files.
  final String include;
  final Set<Type> factories;

  const BundleAdapters({
    this.include = '**',
    this.factories = const {},
  });
}
