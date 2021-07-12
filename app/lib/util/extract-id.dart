/// Make sure that the string is a valid HiveDb ID.
String extractID(String source) {
  final bigEnough = source.padLeft(220);
  return bigEnough.substring(bigEnough.length - 220);
}

extension HiveDbString on String {
  String toHiveId() {
    return extractID(this);
  }
}
