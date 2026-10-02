import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/features/projects/domain/entities/project.dart';

void main() {
  test('derives a key from the initials of a multi-word name', () {
    expect(Project.deriveKey('Mobile Banking App'), 'MBA');
  });

  test('derives a key from the first letters of a single word', () {
    expect(Project.deriveKey('website'), 'WEB');
  });

  test('falls back to PRJ for names without letters', () {
    expect(Project.deriveKey('  --  '), 'PRJ');
  });

  test('displayKey prefers the explicit key, uppercased', () {
    const project = Project(name: 'Mobile', description: '', key: 'mob');
    expect(project.displayKey, 'MOB');
  });
}
