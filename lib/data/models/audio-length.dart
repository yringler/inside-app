import 'package:json_annotation/json_annotation.dart';

part 'audio-length.g.dart';

/// For now, lengths of audio files are kept in a seperate JSON resource file.
/// This model simplifes its parsing.
@JsonSerializable(fieldRename: FieldRename.pascal)
class AudioLength {
  final String source;

  @JsonKey(name: 'Duration')
  final int milliseconds;

  AudioLength({this.source, this.milliseconds});

  factory AudioLength.fromJson(Map<String, dynamic> json) => _$AudioLengthFromJson(json);
}