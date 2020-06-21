import 'dart:io';

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../models/dependency.dart';
import '../models/pdf_content.dart';

class MDGenerator {
  static final sb = StringBuffer();
  static final _dateFormater = DateFormat('MMMM dd yyyy HH:mm');

  static Future<void> createExport({@required ReportContent content, String outputFilepath}) async {
    sb.clear();

    // meta
    sb.writeln('# ${content.title}');
    sb.writeln();
    sb.writeln('| | |');
    sb.writeln('|-|-|');
    sb.writeln('|Project Name|${content.projectName}|');
    sb.writeln('|Project Version|${content.projectVersion}|');
    sb.writeln('|Number of Dependencies|${content.totalNumberDependencies.toString()}|');
    sb.writeln('|Date|${_dateFormater.format(DateTime.now())}|');
    sb.writeln();

    //sdks
    sb.writeln('## SDKs');
    sb.writeln();
    sb.writeln('|Name|Version|');
    sb.writeln('|-|-|');
    for (final sdk in content.sdks) {
      sb.writeln('|${sdk.name}|${sdk.version}|');
    }
    sb.writeln();

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
    file.writeAsStringSync(sb.toString());
  }

  static void _generateTableNameVersion({
    @required String title,
    @required List<Dependency> deps,
  }) {
    sb.writeln('## $title');
    sb.writeln();
    if (deps.isEmpty) {
      sb.writeln('None.');
    } else {
      sb.writeln('|Name|Version|');
      sb.writeln('|-|-|');
      for (final dep in deps) {
        sb.writeln('|${dep.name}|${dep.version}|');
      }
    }
    sb.writeln();
  }

  static void _generateTableNameVersionLicenseScore({
    @required String title,
    @required List<Dependency> deps,
  }) {
    sb.writeln('## $title');
    sb.writeln();
    if (deps.isEmpty) {
      sb.writeln('None.');
    } else {
      sb.writeln('|Name|Version|License|Score|');
      sb.writeln('|-|-|-|-|');
      for (final dep in deps) {
        if (dep.url != null) {
          sb.write('|[${dep.name}](${dep.url})|');
        } else {
          sb.write('|${dep.name}|');
        }

        if (dep.version != null) {
          sb.write('${dep.version}|${dep.license ?? ''}|${dep.score ?? ''}|');
        } else {
          sb.write('Part of sdk| | |');
        }
        sb.write('\n');
      }
    }
    sb.writeln();
  }

  static void _generateTableNameVersionLicenseRef({
    @required String title,
    @required List<Dependency> deps,
  }) {
    sb.writeln('## $title');
    sb.writeln();
    if (deps.isEmpty) {
      sb.writeln('None.');
    } else {
      sb.writeln('|Name|Version|License|Ref|');
      sb.writeln('|-|-|-|-|');
      for (final dep in deps) {
        if (dep.url != null) {
          sb.write('|[${dep.name}](${dep.url})|');
        } else {
          sb.write('|${dep.name}|');
        }
        sb.write('${dep.version}|${dep.license ?? ''}|${dep.ref ?? ''}|\n');
      }
    }
    sb.writeln();
  }
}
