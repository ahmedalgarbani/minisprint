import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/utils/date_math.dart';

void main() {
  test('counts calendar days regardless of the time of day', () {
    expect(
      calendarDaysBetween(DateTime(2026, 3, 1, 23), DateTime(2026, 3, 15, 1)),
      14,
    );
  });

  test('is negative when the second date is earlier', () {
    expect(calendarDaysBetween(DateTime(2026, 1, 3), DateTime(2026, 1, 1)), -2);
  });

  test('adds calendar days across month ends and drops the time', () {
    expect(
      addCalendarDays(DateTime(2026, 1, 25, 23, 30), 14),
      DateTime(2026, 2, 8),
    );
  });
}
