import 'package:hive/hive.dart';

part 'inside-data-base.g.dart';

// Some basic information which many inside data objects have.
@HiveType()
class InsideDataBase {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final List<String> pdf;

  InsideDataBase({this.title, this.description, this.pdf});
}
