import 'package:meta/meta.dart';

/// A model representing a sdk dependency
class SDK {
  /// The sdk name
  final String name;

  /// The sdk version
  final String version;

  /// Constructs a new instance of `Dependency`
  ///
  /// [name] and [version] are required
  const SDK({
    @required this.name,
    @required this.version,
  });
}
