/// An enum describing the types of dependency a report can contain
enum DependencyType {
  /// A direct dependency
  direct,

  /// A dev dependency
  dev,

  /// A transitive dependency
  transitive,

  /// A dependency resolved using git
  ///
  /// Could be direct, dev or transitive
  git,

  /// A dependency resolved using path
  ///
  /// Could be direct, dev or transitive
  path,
}
