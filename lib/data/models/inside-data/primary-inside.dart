import 'dart:core';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'index.dart';

part 'primary-inside.g.dart';

@HiveType()
@JsonSerializable(fieldRename: FieldRename.pascal)
class PrimaryInside {
  /// ID of the section.
  @HiveField(3)
  @JsonKey(name: "ID")
  final String id;

  @HiveField(4)
  final String image;

  @JsonKey(ignore: true)
  SiteSection section;

  PrimaryInside({this.id, this.image, this.section});

  factory PrimaryInside.fromJson(Map<String, dynamic> json) =>
      _$PrimaryInsideFromJson(json);
}
