import 'package:json_annotation/json_annotation.dart';

part 'audio-length.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal)
class AudioLength {
  final String source;

  @JsonKey(name: 'Duration')
  final int milliseconds;

  AudioLength({this.source, this.milliseconds});

  factory AudioLength.fromJson(Map<String, dynamic> json) => _$AudioLengthFromJson(json);
}