import 'package:example/adapters/my_adapters.bundle.dart';
import 'package:mek_adaptable/mek_adaptable.dart';

@BundleAdapters(
  factories: {List<int>},
)
final ciao = $ciao;
