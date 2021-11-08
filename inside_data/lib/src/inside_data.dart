import 'package:json_annotation/json_annotation.dart';

part 'inside_data.g.dart';

class SiteDataBase {
  final Set<String> parents;
  final String id;

  /// Human readable title. (Not a slug)
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
      required this.link,
      required this.parents});

  SiteDataBase.copy(SiteDataBase other)
      : id = other.id,
        title = other.title,
        description = other.description,
        sort = other.sort,
        parents = other.parents,
        link = other.link;
}

@JsonSerializable()
class Media extends SiteDataBase {
  final String source;
  Duration? length;

  Media(
      {required this.source,
      this.length,
      required String id,
      required int sort,
      required String title,
      required String description,
      String link = '',
      required Set<String> parents})
      : super(
            id: id,
            title: title,
            description: description,
            sort: sort,
            parents: parents,
            link: link);

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
  Map<String, dynamic> toJson() => _$MediaToJson(this);
}

enum ContentType { media, section }

/// Holds one of [Media] or [Section].
@JsonSerializable()
class ContentReference {
  final String id;
  final ContentType contentType;
  final Media? media;
  final Section? section;

  ContentReference(
      {this.media, this.section, required this.id, required this.contentType}) {
    // Both datums may not have a value in one ContentReference instance.
    assert(media == null || section == null);
    assert(this.id.isNotEmpty);
  }

  factory ContentReference.fromId(
          {required String id, required ContentType contentType}) =>
      ContentReference(id: id, contentType: contentType);

  factory ContentReference.fromData({required SiteDataBase data}) {
    final media = data is Media ? data : null;
    final section = data is Section ? data : null;
    assert((media ?? section) != null);
    assert(media == null || section == null);
    final type = media != null ? ContentType.media : ContentType.section;

    return ContentReference(
        id: data.id, contentType: type, media: media, section: section);
  }

  factory ContentReference.fromJson(Map<String, dynamic> json) =>
      _$ContentReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$ContentReferenceToJson(this);

  bool get isMedia => contentType == ContentType.media;
  bool get isSection => contentType == ContentType.section;
  bool get hasMedia => media != null;
  bool get hasSection => section != null;
}

@JsonSerializable()
class Section extends SiteDataBase {
  int audioCount = 0;
  final List<ContentReference> content;

  Section(
      {required this.content,
      required String id,
      required int sort,
      required String title,
      required String description,
      required String link,
      required Set<String> parents})
      : super(
            id: id,
            parents: parents,
            title: title,
            description: description,
            sort: sort,
            link: link);

  Section.fromBase(SiteDataBase base, {required this.content})
      : super.copy(base);

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

/// The entire website. In one object. Ideally, this would only be used server side.
@JsonSerializable()
class SiteData {
  final DateTime createdDate;
  final Map<String, Section> sections;
  final List<int> topSectionIds;

  SiteData(
      {required this.sections,
      required this.topSectionIds,
      DateTime? createdDate})
      : this.createdDate = createdDate ?? DateTime.now() {
    var processing = Map<String, int?>();
    for (final id in sections.keys) {
      _setAudioCount(processing, id);
    }
  }

  SiteData.fromList(
      {required List<Section> sections, required List<int> topSectionIds})
      : this(
            sections: {for (var section in sections) section.id: section},
            topSectionIds: topSectionIds);

  Map<String, dynamic> toJson() => _$SiteDataToJson(this);

  int _setAudioCount(Map<String, int?> processing, String sectionId) {
    // Could either mean that we're in the middle of proccessing the section, and
    // the navigation circles back to itself.
    // Or, that we already finished processing the ID, and now we're processing an
    // ancestor.
    if (processing.containsKey(sectionId)) {
      return processing[sectionId] ?? 0;
    }

    final section = sections[sectionId];

    // This should never happen - there's one case where we can't get data from a
    // series, but hopefully that will be resolved soon.
    if (section == null) {
      return 0;
    }

    // Handle empty sections.
    if (section.content.isEmpty) {
      processing[sectionId] = section.audioCount = 0;
      return 0;
    }

    // Keep track so that if this section ends up, through its children,
    // referencing itself, we can gracefully return 0.
    processing[sectionId] = null;

    // Count how many classes are directly in this section.
    final audioCount = section.content
        .map((e) => e.isMedia ? 1 : _setAudioCount(processing, e.id))
        .reduce((value, element) => value + element);

    // Save the audio count.
    processing[sectionId] = section.audioCount = audioCount;

    return section.audioCount;
  }
}

/// Provides initial access to load all of site.
/// After the whole site is loaded, it is copied into a data layer.
abstract class SiteDataLoader {
  /// If no data, load will load data, and trigger to prepare updates for next time.
  /// If [ensureLatest] is true, will ensure that latest data is used now (instead of
  /// just being prepared to use next time).
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
