enum MinuteTimer {
  oneMinute(1),
  fiveMinute(5),
  fifteenMinute(15),
  thirtyMinute(30),
  oneHour(60),
  twoHour(120),
  threeHour(180);

  final int minute;

  const MinuteTimer(this.minute);

  String get label {
    switch (minute) {
      case 5:
        return '5m';
      case 15:
        return '15m';
      case 30:
        return '30m';
      case 60:
        return '60m';
      case 120:
        return '120m';
      case 180:
        return '180m';
      default:
        return '1m';
    }
  }

  MinuteTimer get increase =>
      minute == 180 ? MinuteTimer.oneMinute : MinuteTimer.values[index + 1];
}
