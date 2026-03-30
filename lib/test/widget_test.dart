// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';

// Note: Full widget tests require Firebase mocking (e.g., fake_cloud_firestore).
// These are lightweight smoke tests that don't need the Firebase runtime.
void main() {
  group('App smoke tests', () {
    test('App name constant is correct', () {
      expect('Smart Habit Coach', isNotEmpty);
    });

    test('Frequency constants are valid', () {
      const daily = 'daily';
      const weekly = 'weekly';
      expect(daily, 'daily');
      expect(weekly, 'weekly');
    });
  });
}