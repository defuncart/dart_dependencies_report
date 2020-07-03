import 'dart:io';

import 'package:dart_dependencies_report/dart_dependencies_report.dart' show Settings, UserDefinedGroup;
import 'package:yaml/yaml.dart';

import '../extensions/map_extensions.dart';

/// A class of arguments which the user can specify in pubspec.yaml
class YamlArguments {
  static const title = 'title';
  static const outputDirectory = 'output_dir';
  static const outputFilename = 'output_filename';
  static const generatePdf = 'generate_pdf';
  static const generateMd = 'generate_md';
  static const userDefinedGroups = 'user_defined_groups';
}

/// A class which parses yaml
class YamlParser {
  /// The path to the pubspec file path
  static const pubspecFilePath = 'pubspec.yaml';

  /// The section id for package settings in the yaml file
  static const yamlPackageSectionId = 'dart_dependencies_report';

  /// Returns the package settings from pubspec
  static Settings packageSettingsFromPubspec() {
    final yamlMap = _packageSettingsAsYamlMap();

    return Settings(
      title: yamlMap.tryParse(YamlArguments.title),
      outputDirectory: yamlMap.tryParse(YamlArguments.outputDirectory),
      outputFilename: yamlMap.tryParse(YamlArguments.outputFilename),
      generatePdf: yamlMap.tryParse(YamlArguments.generatePdf),
      generateMd: yamlMap.tryParse(YamlArguments.generateMd),
      userDefinedGroups: _userRegionsFromYamlMap(yamlMap.tryParse(YamlArguments.userDefinedGroups)),
    );
  }

  /// Returns the package settings from pubspec as a yaml map
  static Map<dynamic, dynamic> _packageSettingsAsYamlMap() {
    final file = File(pubspecFilePath);
    final yamlString = file.readAsStringSync();
    final Map<dynamic, dynamic> yamlMap = loadYaml(yamlString);
    return yamlMap[yamlPackageSectionId];
  }

  /// Parses and retuns a List<UserDefinedRegion> from a YamlMap
  static List<UserDefinedGroup> _userRegionsFromYamlMap(YamlMap map) {
    if (map != null) {
      return map.entries.map((kvp) => UserDefinedGroup(title: kvp.key, nameRegexp: kvp.value)).toList();
    }

    return null;
  }
}
