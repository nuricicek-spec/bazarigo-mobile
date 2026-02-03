import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Initial Tests', () {
    test('Math operations work correctly', () {
      expect(1 + 1, 2);
      expect(2 * 2, 4);
      expect(10 / 2, 5);
    });

    test('String operations work correctly', () {
      const greeting = 'Hello';
      const name = 'Bazarigo';
      expect('$greeting $name', 'Hello Bazarigo');
    });

    test('List operations work correctly', () {
      final list = [1, 2, 3, 4, 5];
      expect(list.length, 5);
      expect(list.first, 1);
      expect(list.last, 5);
    });
  });
}
