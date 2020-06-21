import 'package:meta/meta.dart';

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

  /// Constructs a new instance of [Settings]
  ///
  /// All properties are required
  const Settings({
    @required this.title,
    @required this.outputDirectory,
    @required this.outputFilename,
    @required this.generatePdf,
    @required this.generateMd,
  });
}
