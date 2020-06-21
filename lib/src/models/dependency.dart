import 'package:meta/meta.dart';

class Dependency {
  final String name;
  final String version;
  final String score;
  final String about;
  final String license;
  final String url;
  final String ref;

  const Dependency({
    @required this.name,
    this.version,
    this.score,
    this.about,
    this.license,
    this.url,
    this.ref,
  }) : assert(name != null);

  @override
  String toString() {
    final sb = StringBuffer('{name: $name');
    final properties = {
      'version': version,
      'score': score,
      'about': about,
      'license': license,
      'url': url,
      'ref': ref,
    };
    for (final kvp in properties.entries) {
      if (kvp.value != null) {
        sb.write(', ${kvp.key}: ${kvp.value}');
      }
    }
    sb.write('}');
    return sb.toString();
  }
}
