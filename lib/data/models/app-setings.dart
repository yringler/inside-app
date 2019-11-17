import 'package:hive/hive.dart';

part 'app-setings.g.dart';

@HiveType()
class AppSettings {
  @HiveField(0)
  final int dataVersion;

  AppSettings({this.dataVersion});
}