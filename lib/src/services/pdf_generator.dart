import 'dart:io';

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/dependency.dart';
import '../models/report_content.dart';

/// A service which generates Markdown reports
class PDFGenerator {
  static final _dateFormater = DateFormat('MMMM dd yyyy HH:mm');

  /// Creates and exports a report with [ReportContent] content at [outputFilepath]
  static Future<void> createExport({@required ReportContent content, String outputFilepath}) async {
    pw.Widget _tableForDeps(context, {@required List<Dependency> deps}) => deps.isEmpty
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
          // Direct Dependencies
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          pw.Header(level: 1, text: 'Direct Dependencies'),
          _tableForDeps(context, deps: content.directDeps),
          // Dev Dependencies
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          pw.Header(level: 1, text: 'Dev Dependencies'),
          _tableForDeps(context, deps: content.devDeps),
          // Git Hosted
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          pw.Header(level: 1, text: 'Git Hosted'),
          pw.Table.fromTextArray(
            context: context,
            headerCount: 1,
            data: <List<String>>[
              <String>['Name', 'Version', 'License', 'Ref'],
              for (final dep in content.gitDeps)
                <String>[
                  dep.name,
                  dep.version,
                  dep.license,
                  dep.ref,
                ],
            ],
            columnWidths: {
              0: pw.IntrinsicColumnWidth(flex: 2),
              1: pw.IntrinsicColumnWidth(flex: 1),
              2: pw.IntrinsicColumnWidth(flex: 1),
              3: pw.IntrinsicColumnWidth(flex: 2),
            },
          ),
          // Transitive Dependencies
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          pw.Header(level: 1, text: 'Transitive Dependencies'),
          _tableForDeps(context, deps: content.transitiveDeps),
          // Path Dependencies
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8)),
          pw.Header(level: 1, text: 'Path Dependencies'),
          content.pathDeps.isEmpty
              ? pw.Text('None')
              : pw.Table.fromTextArray(
                  context: context,
                  headerCount: 1,
                  data: <List<String>>[
                    <String>['Name', 'Version'],
                    for (final dep in content.pathDeps)
                      <String>[
                        dep.name,
                        dep.version,
                      ],
                  ],
                ),
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
