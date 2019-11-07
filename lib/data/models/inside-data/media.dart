import 'dart:core';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'index.dart';

part 'media.g.dart';

@HiveType()
@JsonSerializable(fieldRename: FieldRename.pascal)
class Media extends InsideDataBase {
  @HiveField(3)
  final String source;

  Media({this.source, String title, String description, List<String> pdf})
      : super(title: title, description: description, pdf: pdf);

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}
