import 'package:meta/meta.dart';

/// A model representing a package dependency
class Dependency {
  /// The name
  final String name;

  /// The version
  final String version;

  /// The calculated score by pub.dev
  final String score;

  /// The about description
  final String about;

  /// The license
  final String license;

  /// The url (either from pub.dev, self-hosted or git)
  final String url;

  /// The git ref (for git dependencies)
  final String ref;

  /// Constructs a new instance of `Dependency`
  ///
  /// [name] is required, all other properties are optional
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
