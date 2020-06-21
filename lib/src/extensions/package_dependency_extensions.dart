import 'package:pubspec_lock/pubspec_lock.dart';

/// Extenion methods for `PackageDependency`
extension PackageDependencyExtensions on PackageDependency {
  /// Whether dependency is part of sdk
  bool get isSDK => iswitcho(
        sdk: (package) => true,
        otherwise: () => false,
      );

  /// Whether dependency is hosted
  bool get isHosted => iswitcho(
        hosted: (package) => true,
        otherwise: () => false,
      );

  /// Whether dependency is hosted on pub.dev
  bool get isHostedByPubDev => iswitcho(
        hosted: (package) => package.url == 'https://pub.dartlang.org',
        otherwise: () => false,
      );

  /// Whether dependency is resolved from git
  bool get isGit => iswitcho(
        git: (package) => true,
        otherwise: () => false,
      );

  /// Whether dependency is resolved from git using custom matcher
  ///
  /// E.g. `isHostedByCustomGit('defuncart')`
  bool isHostedByCustomGit(String match) => iswitcho(
        git: (package) => package.url.contains(match),
        otherwise: () => false,
      );

  /// Whether dependency is resolved from a path
  bool get isPath => iswitcho(
        path: (package) => true,
        otherwise: () => false,
      );

  /// The dependency's url. Returns `null` for `path` and `sdk`
  String get url => iswitcho(
        hosted: (package) => package.url,
        git: (package) => package.url,
        otherwise: () => null,
      );

  /// Returns the url of a package dependency resolved through git. If the package is otherwise resolved, returns null.
  String get gitUrl => iswitcho(
        git: (package) => package.url,
        otherwise: () => null,
      );

  /// Returns the ref of a package dependency resolved through git. If the package is otherwise resolved, returns null.
  String get gitRef => iswitcho(
        git: (package) => package.ref,
        otherwise: () => null,
      );
}
