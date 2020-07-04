import 'package:meta/meta.dart';

import 'dependency.dart';
import 'sdk.dart';

/// A model representing the content for a report
class ReportContent {
  /// The report's title
  final String title;

  /// The project's name
  final String projectName;

  /// The project's version
  final String projectVersion;

  /// The total number of dependencies
  final int totalNumberDependencies;

  /// A list of sdk dependencies
  final List<SDK> sdks;

  /// A list of direct dependencies
  final List<Dependency> directDeps;

  /// A list of dev dependencies
  final List<Dependency> devDeps;

  /// A list of transitive dependencies
  final List<Dependency> transitiveDeps;

  /// A list of git dependencies
  final List<Dependency> gitDeps;

  /// A list of path dependencies
  final List<Dependency> pathDeps;

  /// A map of string titles to list of dependencies per user defined group
  final Map<String, List<Dependency>> userDefinedGroupsDeps;

  /// Constructs a new instance of [ReportContent]
  ///
  /// All properties are required
  const ReportContent({
    @required this.title,
    @required this.projectName,
    @required this.projectVersion,
    @required this.totalNumberDependencies,
    @required this.sdks,
    @required this.directDeps,
    @required this.devDeps,
    @required this.transitiveDeps,
    @required this.gitDeps,
    @required this.pathDeps,
    @required this.userDefinedGroupsDeps,
  })  : assert(title != null),
        assert(projectName != null),
        assert(projectVersion != null),
        assert(totalNumberDependencies != null),
        assert(sdks != null),
        assert(directDeps != null),
        assert(transitiveDeps != null),
        assert(gitDeps != null),
        assert(pathDeps != null),
        assert(userDefinedGroupsDeps != null);
}
