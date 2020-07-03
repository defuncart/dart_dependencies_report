import 'package:meta/meta.dart';

import 'user_defined_group.dart';

/// A Model representing settings to generate reports
class Settings {
  /// The report's title
  final String title;

  /// The directory to save the report
  final String outputDirectory;

  /// The report's filename
  final String outputFilename;

  /// Whether a pdf should be generated
  final bool generatePdf;

  /// Whether a md should be generated
  final bool generateMd;

  /// A list of user defined groups
  final List<UserDefinedGroup> userDefinedGroups;

  /// Constructs a new instance of [Settings]
  ///
  /// All properties are required
  const Settings({
    @required this.title,
    @required this.outputDirectory,
    @required this.outputFilename,
    @required this.generatePdf,
    @required this.generateMd,
    @required this.userDefinedGroups,
  });

  @override
  String toString() =>
      '{title: $title, outputDirectory: $outputDirectory, outputFilename: $outputFilename, generatePdf: $generatePdf, generateMd: $generateMd, userDefinedGroups: $userDefinedGroups}';
}
