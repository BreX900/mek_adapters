import 'package:meta/meta_meta.dart';

abstract class Adaptable {}

class AdaptableClass {
  const AdaptableClass();
}

@TargetKind.enumType
class AdaptableEnum {
  const AdaptableEnum();
}

@TargetKind.topLevelVariable
class BundleAdapters {
  final Set<Type> factories;

  const BundleAdapters({
    this.factories = const {},
  });
}

enum Ciao implements Adaptable {
  piero;
}
