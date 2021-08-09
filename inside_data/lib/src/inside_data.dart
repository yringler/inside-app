import 'package:json_annotation/json_annotation.dart';

part 'inside_data.g.dart';

class SiteDataBase {
  final String id;
  String title;
  String description;
  final int sort;

  /// A URL to site where this content can be seen.
  final String link;

  SiteDataBase(
      {required this.id,
      required this.title,
      required this.description,
      required this.sort,
      required this.link});
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
      required String description,
      required String link})
      : super(
            id: id,
            title: title,
            description: description,
            sort: sort,
            link: link);

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
      required String description,
      required String link})
      : super(
            id: id,
            title: title,
            description: description,
            sort: sort,
            link: link);

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
  final List<Media> content;

  SiteData({required this.sections, required this.content});
}

/// Provides initial access to load all of site.
/// After the whole site is loaded, it is copied into a data layer.
abstract class SiteDataLoader {
  /// If no data, load will load data, and trigger to prepare updates for next time.
  Future<SiteData> load(DateTime lastLoadTime, {bool ensureLatest = false});
}

// var topImages = {
//   21: 'https://insidechassidus.org/wp-content/uploads/Hayom-Yom-and-Rebbe-Audio-Classes-6.jpg',
//   4: 'https://insidechassidus.org/wp-content/uploads/Chassidus-of-the-Year-Shiurim.jpg',
//   56: 'https://insidechassidus.org/wp-content/uploads/History-and-Kaballah.jpg',
//   28: 'https://insidechassidus.org/wp-content/uploads/Maamarim-and-handwriting.jpg',
//   34: 'https://insidechassidus.org/wp-content/uploads/Rebbe-Sicha-and-Lekutei-Sichos.jpg',
//   45: 'https://insidechassidus.org/wp-content/uploads/Talks-by-Rabbi-Paltiel.jpg',
//   14: 'https://insidechassidus.org/wp-content/uploads/Tanya-Audio-Classes-Alter-Rebbe-2.jpg',
//   40: 'https://insidechassidus.org/wp-content/uploads/Tefillah.jpg',
//   13: 'https://insidechassidus.org/wp-content/uploads/Parsha-of-the-Week-Audio-Classes.jpg'
// };

/// A mapping of category ID to its image.
var topCategories = {
  16: 'https://insidechassidus.org/wp-content/uploads/Hayom-Yom-and-Rebbe-Audio-Classes-6.jpg',
  1475:
      'https://insidechassidus.org/wp-content/uploads/Chassidus-of-the-Year-Shiurim.jpg',
  19: 'https://insidechassidus.org/wp-content/uploads/History-and-Kaballah.jpg',
  17: 'https://insidechassidus.org/wp-content/uploads/Maamarim-and-handwriting.jpg',
  18: 'https://insidechassidus.org/wp-content/uploads/Rebbe-Sicha-and-Lekutei-Sichos.jpg',
  20: 'https://insidechassidus.org/wp-content/uploads/Talks-by-Rabbi-Paltiel.jpg',
  6: 'https://insidechassidus.org/wp-content/uploads/Tanya-Audio-Classes-Alter-Rebbe-2.jpg',
  15: 'https://insidechassidus.org/wp-content/uploads/Tefillah.jpg',
  1447:
      'https://insidechassidus.org/wp-content/uploads/Parsha-of-the-Week-Audio-Classes.jpg',
  1104:
      'https://insidechassidus.org/wp-content/uploads/stories-of-rebbeim-1.jpg'
};
