import 'package:hive/hive.dart';

// Some basic information which many inside data objects have.
class InsideDataBase {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final List<String> pdf;

  InsideDataBase({this.title, this.description, this.pdf});
}
