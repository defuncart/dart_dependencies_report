import 'dart:io';

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../models/dependency.dart';
import '../models/pdf_content.dart';

/// A service which generates Markdown reports
class MDGenerator {
  static final _sb = StringBuffer();
  static final _dateFormater = DateFormat('MMMM dd yyyy HH:mm');

  /// Creates and exports a report with [ReportContent] content at [outputFilepath]
  static Future<void> createExport({@required ReportContent content, String outputFilepath}) async {
    _sb.clear();

    // meta
    _sb.writeln('# ${content.title}');
    _sb.writeln();
    _sb.writeln('| | |');
    _sb.writeln('|-|-|');
    _sb.writeln('|Project Name|${content.projectName}|');
    _sb.writeln('|Project Version|${content.projectVersion}|');
    _sb.writeln('|Number of Dependencies|${content.totalNumberDependencies.toString()}|');
    _sb.writeln('|Date|${_dateFormater.format(DateTime.now())}|');
    _sb.writeln();

    //sdks
    _sb.writeln('## SDKs');
    _sb.writeln();
    _sb.writeln('|Name|Version|');
    _sb.writeln('|-|-|');
    for (final sdk in content.sdks) {
      _sb.writeln('|${sdk.name}|${sdk.version}|');
    }
    _sb.writeln();

    // direct
    _generateTableNameVersionLicenseScore(title: 'Direct Dependencies', deps: content.directDeps);

    // dev
    _generateTableNameVersionLicenseScore(title: 'Dev Dependencies', deps: content.devDeps);

    // git hosted
    _generateTableNameVersionLicenseRef(title: 'Git Hosted', deps: content.gitDeps);

    // transitive
    _generateTableNameVersionLicenseScore(title: 'Transitive Dependencies', deps: content.transitiveDeps);

    // path
    _generateTableNameVersion(title: 'Path Dependencies', deps: content.pathDeps);

    final file = File(outputFilepath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(_sb.toString());
  }

  static void _generateTableNameVersion({
    @required String title,
    @required List<Dependency> deps,
  }) {
    _sb.writeln('## $title');
    _sb.writeln();
    if (deps.isEmpty) {
      _sb.writeln('None.');
    } else {
      _sb.writeln('|Name|Version|');
      _sb.writeln('|-|-|');
      for (final dep in deps) {
        _sb.writeln('|${dep.name}|${dep.version}|');
      }
    }
    _sb.writeln();
  }

  static void _generateTableNameVersionLicenseScore({
    @required String title,
    @required List<Dependency> deps,
  }) {
    _sb.writeln('## $title');
    _sb.writeln();
    if (deps.isEmpty) {
      _sb.writeln('None.');
    } else {
      _sb.writeln('|Name|Version|License|Score|');
      _sb.writeln('|-|-|-|-|');
      for (final dep in deps) {
        if (dep.url != null) {
          _sb.write('|[${dep.name}](${dep.url})|');
        } else {
          _sb.write('|${dep.name}|');
        }

        if (dep.version != null) {
          _sb.write('${dep.version}|${dep.license ?? ''}|${dep.score ?? ''}|');
        } else {
          _sb.write('Part of sdk| | |');
        }
        _sb.write('\n');
      }
    }
    _sb.writeln();
  }

  static void _generateTableNameVersionLicenseRef({
    @required String title,
    @required List<Dependency> deps,
  }) {
    _sb.writeln('## $title');
    _sb.writeln();
    if (deps.isEmpty) {
      _sb.writeln('None.');
    } else {
      _sb.writeln('|Name|Version|License|Ref|');
      _sb.writeln('|-|-|-|-|');
      for (final dep in deps) {
        if (dep.url != null) {
          _sb.write('|[${dep.name}](${dep.url})|');
        } else {
          _sb.write('|${dep.name}|');
        }
        _sb.write('${dep.version}|${dep.license ?? ''}|${dep.ref ?? ''}|\n');
      }
    }
    _sb.writeln();
  }
}
