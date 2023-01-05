enum MinuteTimerPeriod {
  oneMinute,
  fiveMinute,
  fifteenMinute,
  thirtyMinute,
  oneHour,
}

extension MinuteTimerPeriodExt on MinuteTimerPeriod {
  MinuteTimerPeriod get increase => index == MinuteTimerPeriod.values.last.index
      ? MinuteTimerPeriod.oneMinute
      : MinuteTimerPeriod.values[index + 1];

  String get label {
    switch (index) {
      case 0:
        return '1m';
      case 1:
        return '5m';
      case 2:
        return '15m';
      case 3:
        return '30m';
      case 4:
        return '60m';
      default:
        return '1m';
    }
  }

  int get minute {
    switch (index) {
      case 0:
        return 1;
      case 1:
        return 5;
      case 2:
        return 15;
      case 3:
        return 30;
      case 4:
        return 60;
      default:
        return 1;
    }
  }
}
