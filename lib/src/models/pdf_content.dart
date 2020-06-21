import 'package:meta/meta.dart';

import 'dependency.dart';
import 'sdk.dart';

class ReportContent {
  final String title;

  final String projectName;

  final String projectVersion;

  final int totalNumberDependencies;

  final List<SDK> sdks;
  final List<Dependency> directDeps;
  final List<Dependency> devDeps;
  final List<Dependency> transitiveDeps;
  final List<Dependency> gitDeps;
  final List<Dependency> pathDeps;

  const ReportContent({
    @required this.title,
    @required this.projectName,
    @required this.projectVersion,
    @required this.totalNumberDependencies,
    this.sdks,
    this.directDeps,
    this.devDeps,
    this.transitiveDeps,
    this.gitDeps,
    this.pathDeps,
  })  : assert(title != null),
        assert(projectName != null),
        assert(projectVersion != null),
        assert(totalNumberDependencies != null);
}
