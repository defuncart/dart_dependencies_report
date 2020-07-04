import 'dart:io';

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../extensions/dependency_type_extensions.dart';
import '../models/dependency.dart';
import '../models/report_content.dart';

/// A service which generates Markdown reports
class PDFGenerator {
  static final _dateFormater = DateFormat('MMMM dd yyyy HH:mm');

  /// Creates and exports a report with [ReportContent] content at [outputFilepath]
  static Future<void> createExport({@required ReportContent content, String outputFilepath}) async {
    pw.Widget _generateTableNameVersionLicenseScore(
      pw.Context context, {
      @required String title,
      @required List<Dependency> deps,
    }) =>
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 1, text: title),
            deps.isEmpty
                ? pw.Text('None')
                : pw.Table.fromTextArray(
                    context: context,
                    headerCount: 1,
                    data: <List<String>>[
                      <String>['Name', 'Version', 'License', 'Score'],
                      for (final dep in deps)
                        <String>[
                          dep.name,
                          if (dep.version != null) ...[
                            dep.version ?? '',
                            dep.license ?? '',
                            dep.score ?? '',
                          ],
                          if (dep.version == null) 'Part of sdk',
                        ],
                    ],
                    columnWidths: {
                      0: pw.IntrinsicColumnWidth(flex: 3),
                      1: pw.IntrinsicColumnWidth(flex: 1),
                      2: pw.IntrinsicColumnWidth(flex: 1),
                      3: pw.IntrinsicColumnWidth(flex: 1),
                    },
                  ),
          ],
        );

    pw.Widget _generateTableNameVersionType(
      pw.Context context, {
      @required String title,
      @required List<Dependency> deps,
    }) =>
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 1, text: title),
            deps.isEmpty
                ? pw.Text('None')
                : pw.Table.fromTextArray(
                    context: context,
                    headerCount: 1,
                    data: <List<String>>[
                      <String>['Name', 'Version', 'Type'],
                      for (final dep in deps)
                        <String>[
                          dep.name,
                          dep.version,
                          dep.type.displayName,
                        ],
                    ],
                    columnWidths: {
                      0: pw.IntrinsicColumnWidth(flex: 2),
                      1: pw.IntrinsicColumnWidth(flex: 1),
                      2: pw.IntrinsicColumnWidth(flex: 1),
                    },
                  ),
          ],
        );

    pw.Widget _generateTableNameVersionTypeLicenseRef(
      pw.Context context, {
      @required String title,
      @required List<Dependency> deps,
    }) =>
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 1, text: title),
            deps.isEmpty
                ? pw.Text('None')
                : pw.Table.fromTextArray(
                    context: context,
                    headerCount: 1,
                    data: <List<String>>[
                      <String>['Name', 'Version', 'Type', 'License', 'Ref'],
                      for (final dep in deps)
                        <String>[
                          dep.name,
                          dep.version,
                          dep.type.displayName,
                          dep.license,
                          dep.ref,
                        ],
                    ],
                    columnWidths: {
                      0: pw.IntrinsicColumnWidth(flex: 2),
                      1: pw.IntrinsicColumnWidth(flex: 1),
                      2: pw.IntrinsicColumnWidth(flex: 1),
                      3: pw.IntrinsicColumnWidth(flex: 1),
                      4: pw.IntrinsicColumnWidth(flex: 2),
                    },
                  ),
          ],
        );

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (context) {
          if (context.pageNumber == 1) {
            return null;
          }
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: const pw.BoxDecoration(border: pw.BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
            child: pw.Text(
              content.title,
              style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey),
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey),
            ),
          );
        },
        build: (context) => <pw.Widget>[
          pw.Header(
            level: 0,
            child: pw.Text(
              content.title,
              textScaleFactor: 2,
            ),
          ),
          pw.Table.fromTextArray(
            context: context,
            headerCount: 0,
            data: <List<String>>[
              <String>['Project Name', content.projectName],
              <String>['Project Version', content.projectVersion],
              <String>['Number of Dependencies', content.totalNumberDependencies.toString()],
              <String>['Date', _dateFormater.format(DateTime.now())],
            ],
            columnWidths: {
              0: pw.IntrinsicColumnWidth(flex: 1),
              1: pw.IntrinsicColumnWidth(flex: 2),
            },
          ),
          // sdks
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          pw.Header(level: 1, text: 'SDKs'),
          pw.Table.fromTextArray(
            context: context,
            headerCount: 1,
            data: <List<String>>[
              <String>['Name', 'Version'],
              for (final sdk in content.sdks)
                <String>[
                  sdk.name,
                  sdk.version,
                ],
            ],
          ),
          // user defined
          for (final kvp in content.userDefinedGroupsDeps.entries)
            pw.Column(
              children: [
                pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
                _generateTableNameVersionType(context, title: kvp.key, deps: kvp.value),
              ],
            ),
          // direct
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          _generateTableNameVersionLicenseScore(context, title: 'Direct Dependencies', deps: content.directDeps),
          // dev
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          _generateTableNameVersionLicenseScore(context, title: 'Dev Dependencies', deps: content.devDeps),
          // git
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          _generateTableNameVersionTypeLicenseRef(context, title: 'Git Hosted', deps: content.gitDeps),
          // transitive
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          _generateTableNameVersionLicenseScore(context,
              title: 'Transitive Dependencies', deps: content.transitiveDeps),
          // path
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          _generateTableNameVersionType(context, title: 'Path Dependencies', deps: content.pathDeps),
        ],
      ),
    );

    final file = File(outputFilepath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    await file.writeAsBytes(doc.save());
  }
}

// class _UrlText extends pw.StatelessWidget {
//   _UrlText(this.text, this.url);

//   final String text;
//   final String url;

//   @override
//   pw.Widget build(pw.Context context) {
//     return pw.UrlLink(
//       destination: url,
//       child: pw.Text(text,
//           style: const pw.TextStyle(
//             decoration: pw.TextDecoration.underline,
//             color: PdfColors.blue,
//           )),
//     );
//   }
// }
