/// Converts duration into string with minutes and seconds components.
String toDurationString(Duration? duration) {
  if (duration == null) {
    return "--:--";
  }

  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds - minutes * Duration.secondsPerMinute;

  return "${_toPaddedNumber(minutes)}: ${_toPaddedNumber(seconds)}";
}

String _toPaddedNumber(int number) {
  return number.toString().padLeft(2, "0");
}
