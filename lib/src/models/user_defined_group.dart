import 'package:meta/meta.dart';

/// A group which the user can define
class UserDefinedGroup {
  /// The group's title
  final String title;

  /// A regexp of matchable dependency names
  final RegExp nameRegexp;

  /// Constructs a new instance of [UserDefinedGroup]
  ///
  /// All properties are required
  UserDefinedGroup({
    @required this.title,
    @required String nameRegexp,
  })  : assert(title != null),
        assert(nameRegexp != null),
        nameRegexp = nameRegexp != null ? RegExp(nameRegexp) : null;

  @override
  String toString() => '{title: $title, nameRegexp: $nameRegexp}';
}
