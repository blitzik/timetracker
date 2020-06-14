class TimeUtils {
  static DateTime findClosestTime(DateTime time, int step) {
    int hour = time.hour;
    int minutes;
    int transitionalMinute = (60 - (step / 2)).floor();
    if (time.minute > transitionalMinute) {
      hour++;
      minutes = 0;

    } else {
      minutes = (time.minute / step).round() * step;
    }

    return DateTime(time.year, time.month, time.day, hour, minutes, 0, 0, 0);
  }
}