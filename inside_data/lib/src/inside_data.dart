import 'package:json_annotation/json_annotation.dart';

part 'inside_data.g.dart';

class SiteDataBase {
  final String id;
  final String title;
  final String description;
  final int sort;

  SiteDataBase(
      {required this.id,
      required this.title,
      required this.description,
      required this.sort});
}

@JsonSerializable()
class Media extends SiteDataBase {
  final String source;
  final Duration length;

  Media(
      {required this.source,
      required this.length,
      required String id,
      required int sort,
      required String title,
      required String description})
      : super(id: id, title: title, description: description, sort: sort);

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
  Map<String, dynamic> toJson() => _$MediaToJson(this);
}

/// Holds one of [Media] or [Section]. Has a value method which is the non null value.
@JsonSerializable()
class ContentReference {
  final Media? media;
  final Section? section;
  final SiteDataBase value;

  ContentReference({this.media, this.section}) : value = (media ?? section)! {
    // 1 and only 1 must be not null.
    assert((media ?? section) != null);
    assert(media == null || section == null);
  }

  factory ContentReference.fromJson(Map<String, dynamic> json) =>
      _$ContentReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$ContentReferenceToJson(this);

  bool get isMedia => media != null;
  bool get isSection => section != null;
}

@JsonSerializable()
class Section extends SiteDataBase {
  final int audioCount;
  final List<ContentReference> content;

  Section(
      {required this.audioCount,
      required this.content,
      required String id,
      required int sort,
      required String title,
      required String description})
      : super(id: id, title: title, description: description, sort: sort);

  factory Section.fromJson(Map<String, dynamic> json) =>
      _$SectionFromJson(json);
  Map<String, dynamic> toJson() => _$SectionToJson(this);
}

/// Provides access to site data.
abstract class SiteDataLayer {
  Future<void> init();
  List<Section> topLevel();
  Future<Section> section(String id);
  Future<Media> media(String id);
}

class SiteData {
  final List<Section> sections;
  final List<ContentReference> content;

  SiteData({required this.sections, required this.content});
}

/// Provides initial access to load all of site.
/// After the whole site is loaded, it is copied into a data layer.
abstract class SiteDataLoader {
  /// If no data, load will load data, and trigger to prepare updates for next time.
  Future<SiteData> load(Duration lastLoadTime, {bool ensureLatest = false});
}
