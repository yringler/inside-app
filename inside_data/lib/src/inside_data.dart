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

  int compareTo(SiteDataBase other) => this.sort.compareTo(other.sort);
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
  bool get hasValue => hasMedia || hasSection;
  SiteDataBase? get value => media ?? section;

  int compareTo(ContentReference other) =>
      this.hasValue && other.hasValue ? this.value!.compareTo(other.value!) : 0;
}

@JsonSerializable()
class Section extends SiteDataBase {
  int audioCount = 0;
  final List<ContentReference> content;

  /// If content of section was loaded, or just the section base data.
  /// For example, loading a section might load all parent sections, but not ad infinitum -
  /// it will only load the basic data (title etc) of its child sections.
  /// TODO: should [content] be nullable? Diffirent way of handling this?
  final bool loadedContent;

  Section(
      {required this.content,
      required String id,
      required int sort,
      required String title,
      required String description,
      required String link,
      required Set<String> parents,
      this.loadedContent = true})
      : super(
            id: id,
            parents: parents,
            title: title,
            description: description,
            sort: sort,
            link: link);

  Section.fromBase(SiteDataBase base,
      {required this.content, this.loadedContent = true})
      : super.copy(base);

  factory Section.fromJson(Map<String, dynamic> json) =>
      _$SectionFromJson(json);
  Map<String, dynamic> toJson() => _$SectionToJson(this);
}

/// Provides access to site data.
abstract class SiteDataLayer {
  Future<void> init();
  Future<List<Section>> topLevel();
  Future<Section?> section(String id);
  Future<Media?> media(String id);
}

/// The entire website. In one object. Ideally, this would only be used server side.
@JsonSerializable()
class SiteData {
  final DateTime createdDate;
  final Map<String, Section> sections;
  final List<int> topSectionIds;

  /// All medias, extracted from [sections].
  Iterable<Media> get medias => sections.values
      .map((e) => e.content)
      .expand((element) => element)
      .map((e) => [
            if (e.hasMedia) e.media!,
            if (e.hasSection)
              ...e.section!.content
                  .where((element) => element.hasMedia)
                  .map((e) => e.media!)
          ])
      .expand((element) => element);

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

  /// Create site data from list of sections. We support one level of recursion - a section can be in a section,
  /// but no more than that.
  /// This corresponds to a wordpress section, which can be in a category.
  /// But a nested category is only connected to its parent via the childs parent property,
  /// and must be in the first level of [sections].
  SiteData.fromList(
      {required List<Section> sections, required List<int> topSectionIds})
      : this(sections: {
          for (var section in sections
              .map((e) => [
                    e,
                    ...e.content
                        .where((element) =>
                            element.isSection && element.section != null)
                        .map((e) => e.section!)
                        .toList()
                  ])
              .expand((element) => element)
              .toSet())
            section.id: section
        }, topSectionIds: topSectionIds);

  Map<String, dynamic> toJson() => _$SiteDataToJson(this);

  factory SiteData.fromJson(Map<String, dynamic> json) =>
      _$SiteDataFromJson(json);

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
  /// Called when there is no data in the in app DB. Take data from quickest possible source,
  /// eg pre-loaded resources.
  Future<SiteData> initialLoad();

  /// Will load data now if it is readily available, and check for updates for next time.
  /// Will use updated data now if [ensureLatest] is set to true.
  Future<SiteData?> load(DateTime lastLoadTime, {bool ensureLatest = false});
}
