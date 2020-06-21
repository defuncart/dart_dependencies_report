import 'package:dart_dependencies_report/dart_dependencies_report.dart';

import 'utils/yaml_parser.dart';

void main() {
  final packageSettings = YamlParser.packageSettingsFromPubspec();

  DependencyReport.generate(packageSettings);
}
