import 'dart:core';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'index.dart';

part 'media.g.dart';

@HiveType()
@JsonSerializable(fieldRename: FieldRename.pascal)
class Media implements InsideDataBase {
  @HiveField(3)
  final String source;

  Media({this.source, this.title, this.description, List<String> pdf});

  @HiveField(0)
  @override
  String description;

  @HiveField(1)
  @override
  List<String> pdf;

  @HiveField(2)
  @override
  String title;

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}
