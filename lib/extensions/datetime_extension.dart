extension DateTimeExtension on DateTime {
  int getWeek() {
    DateTime monday = weekStart();
    DateTime first = _weekYearStartDate(monday.year);

    int week = 1 + (monday.difference(first).inDays / 7).floor();

    if (week == 53 && DateTime.utc(monday.year, 12, 31).weekday < 4)
      week = 1;

    return week;
  }


  DateTime weekStart() {
    var date = this;
    DateTime monday = DateTime.utc(date.year, date.month, date.day);
    monday = monday.subtract(Duration(days: monday.weekday - 1));

    return monday;
  }


  DateTime weekEnd() {
    var date = this;
    DateTime monday = date.weekStart();
    DateTime sunday = monday.add(Duration(days: 6));

    return sunday;
  }


  DateTime _weekYearStartDate(int year) {
    final firstDayOfYear = DateTime.utc(year, 1, 1);
    final dayOfWeek = firstDayOfYear.weekday;

    return firstDayOfYear.add(Duration(days: (dayOfWeek <= DateTime.thursday ? 1 : 8) - dayOfWeek));
  }
}