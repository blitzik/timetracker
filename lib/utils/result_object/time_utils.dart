class TimeUtils {
  static DateTime findClosestTime(DateTime time, int step) {
    int transitionalMinute = (60 - (step / 2)).floor();
    if (time.minute > transitionalMinute) {
      time = time.add(Duration(hours: 1));
      time = DateTime(time.year, time.month, time.day, time.hour, 0, 0, 0);

    } else {
      time = DateTime(
          time.year, time.month, time.day,
          time.hour,  ((time.minute / step).round() * step), 0, 0, 0);
    }

    return DateTime.utc(time.year, time.month, time.day, time.hour, time.minute, 0, 0, 0);
  }
}