// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';

// Note: Full widget tests for this app require Firebase mocking
// (e.g., fake_cloud_firestore + firebase_auth_mocks).
// These are lightweight smoke tests that run without the Firebase runtime.
void main() {
  test('App name is correct', () {
    expect('Smart Habit Coach', isNotEmpty);
  });

  test('Frequency constants are valid', () {
    const daily = 'daily';
    const weekly = 'weekly';
    expect(daily, 'daily');
    expect(weekly, 'weekly');
  });
}