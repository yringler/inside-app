import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'inside-data/index.dart';

part 'inside-data-json-root.g.dart';

/// Model to parse inside data json.
@JsonSerializable(fieldRename: FieldRename.pascal)
class InsideDataJsonRoot {
  Map<String, SiteSection> sections;
  Map<String, Lesson> lessons;
  List<PrimaryInside> topLevel;

  InsideDataJsonRoot(this.sections, this.lessons, this.topLevel) {
    for (var item in topLevel) {
      item.section = sections[item.id];
    }
  }

  factory InsideDataJsonRoot.fromJson(Map<String, dynamic> json) =>
      _$InsideDataJsonRootFromJson(json);
}
