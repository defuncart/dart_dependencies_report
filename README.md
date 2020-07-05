# dart_dependencies_report

A package which generates a report of all a project's dependencies.

## Example

Firstly add `dart_dependencies_report` as a dev dependency:

```yml
dart_dependencies_report:
  git:
    url: https://github.com/defuncart/dart_dependencies_report
```

From the project's root run

```sh
flutter pub run dart_dependencies_report
```

which will create `dependencies_report.md` in `/reports`. To optionally specify output path, filename and filetypes, add the following settings to `pubspec.yaml`:

```yaml
dart_dependencies_report:
  title: Dependencies Report
  output_dir: ''
  output_filename: dependencies_report
  generate_pdf: true
  generate_md: true
  user_defined_groups:
    "defuncart" : "flutter_analysis_options|dart_dependencies_report"
```

`user_defined_groups` can be used to create specified groups in the report, in this case a group of dependencies maintained by defuncart.
