import 'package:pubspec_lock/pubspec_lock.dart';

/// Extenion methods for `DependencyType`
extension DependencyTypeExtensions on DependencyType {
  static const _mapTypeString = {
    DependencyType.direct: 'direct',
    DependencyType.development: 'dev',
    DependencyType.transitive: 'transitive',
  };

  /// Returns a display name for the [DependencyType]
  String get displayName => _mapTypeString[this];
}
