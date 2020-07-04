import 'package:dart_dependencies_report/src/extensions/dependency_type_extensions.dart';
import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:test/test.dart';

void main() {
  test('displayName', () {
    expect(DependencyType.direct.displayName, 'direct');
    expect(DependencyType.development.displayName, 'dev');
    expect(DependencyType.transitive.displayName, 'transitive');
  });
}
