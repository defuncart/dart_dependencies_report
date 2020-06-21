/// Extension methods for `Map`
extension MapExtensions on Map {
  /// Tries to parse a map with a given key
  dynamic tryParse(dynamic key) => this != null && containsKey(key) ? this[key] : null;
}
