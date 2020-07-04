/// Returns a short description of an enum value.
///
/// Strips off the enum class name from the enumEntry.toString().
/// Taken from Flutter Foundation
String describeEnum(Object enumEntry) {
  final description = enumEntry.toString();
  final indexOfDot = description.indexOf('.');
  assert(indexOfDot != -1 && indexOfDot < description.length - 1);
  return description.substring(indexOfDot + 1);
}
