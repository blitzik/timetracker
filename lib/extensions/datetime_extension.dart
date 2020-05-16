extension DateTimeExtension on DateTime {
  int getWeek() {
    DateTime monday = weekStart();
    DateTime first = _weekYearStartDate(monday.year);

    int week = 1 + (monday.difference(first).inDays / 7).floor();

    if (week == 53 && DateTime(monday.year, 12, 31).weekday < 4)
      week = 1;

    return week;
  }


  DateTime weekStart() {
    var date = this;
    // This is ugly, but to avoid problems with daylight saving
    DateTime monday = DateTime.utc(date.year, date.month, date.day);
    monday = monday.subtract(Duration(days: monday.weekday - 1));

    return monday;
  }


  DateTime weekEnd() {
    var date = this;
    // This is ugly, but to avoid problems with daylight saving
    // Set the last microsecond to really be the end of the week
    DateTime sunday = DateTime.utc(date.year, date.month, date.day, 23, 59, 59, 999, 999999);
    sunday = sunday.add(Duration(days: 7 - sunday.weekday));

    return sunday;
  }


  DateTime _weekYearStartDate(int year) {
    final firstDayOfYear = DateTime.utc(year, 1, 1);
    final dayOfWeek = firstDayOfYear.weekday;

    return firstDayOfYear.add(Duration(days: (dayOfWeek <= DateTime.thursday ? 1 : 8) - dayOfWeek));
  }
}