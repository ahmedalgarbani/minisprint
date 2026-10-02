// Calendar-day arithmetic that is immune to daylight-saving transitions
// (a `Duration(days: 1)` is 24 h, not always one calendar day).

/// [date] moved by [days] calendar days, keeping only the date part.
DateTime addCalendarDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

/// Whole calendar days from [from] to [to] (negative if [to] is earlier).
int calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
