import 'package:inside_data/inside_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'inside_data.g.dart';

class SiteDataBase implements Comparable {
  final Set<String> parents;
  final String id;

  /// Human readable title. (Not a slug)
  String title;
  String description;
  final int sort;

  /// A URL to site where this content can be seen.
  final String link;

  String? get firstParent => hasParent ? parents.first : null;
  bool get hasParent => parents.isNotEmpty;
  bool hasParentId(String id) => parents.contains(id);

  final DateTime? created;

  SiteDataBase(
      {required this.id,
      required this.title,
      required this.description,
      required this.sort,
      required this.link,
      required this.parents,
      this.created});

  SiteDataBase.copy(SiteDataBase other)
      : id = other.id,
        title = other.title,
        description = other.description,
        sort = other.sort,
        parents = other.parents,
        link = other.link,
        created = other.created;

  @override
  int compareTo(other) => this.sort.compareTo(other.sort);
}

@JsonSerializable()
class Media extends SiteDataBase implements Comparable {
  int? _hashcode;
  final String source;
  Duration? length;

  Media(
      {required this.source,
      required this.length,
      required String id,
      required int sort,
      required String title,
      required String description,
      required String link,
      required Set<String> parents,
      DateTime? created})
      : super(
            id: id,
            title: title,
            description: description,
            sort: sort,
            parents: parents,
            created: created,
            link: link);

  Future<Section?> getParent(SiteDataLayer siteBoxes) async {
    if (parents.isEmpty) return null;

    final parentSection = await siteBoxes.section(parents.first);

    // Make sure that the parent exists, and that it really has the data.
    // This is done in case IDs change etc - we don't want to navigate to library,
    // to some random place.
    if (parentSection == null ||
        !parentSection.content.any((c) => c.media == this)) {
      return null;
    }

    return parentSection;
  }

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
  Map<String, dynamic> toJson() => _$MediaToJson(this);

  @override
  bool operator ==(other) {
    if (other is! Media) {
      return false;
    }

    return source == other.source && id == other.id;
  }

  @override
  int get hashCode => _hashcode ??= [id, source].join('').hashCode;
}

enum ContentType { media, section }

/// Holds one of [Media] or [Section].
@JsonSerializable()
class ContentReference implements Comparable {
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

  static ContentReference? fromDataOrNull({SiteDataBase? data}) =>
      data == null ? null : ContentReference.fromData(data: data);

  factory ContentReference.fromJson(Map<String, dynamic> json) =>
      _$ContentReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$ContentReferenceToJson(this);

  bool get isMedia => contentType == ContentType.media;
  bool get isSection => contentType == ContentType.section;
  bool get hasMedia => media != null;
  bool get hasSection => section != null;
  bool get hasValue => hasMedia || hasSection;
  SiteDataBase? get value => media ?? section;

  int compareTo(other) =>
      other is ContentReference && this.hasValue && other.hasValue
          ? this.value!.compareTo(other.value!)
          : 0;
}

@JsonSerializable()
class Section extends SiteDataBase {
  int audioCount;
  final List<ContentReference> content;

  /// If content of section was loaded, or just the section base data.
  /// For example, loading a section might load all parent sections, but not ad infinitum -
  /// it will only load the basic data (title etc) of its child sections.
  /// TODO: should [content] be nullable? Diffirent way of handling this?
  final bool loadedContent;

  int? _hashcode;

  Section(
      {required this.content,
      required String id,
      required int sort,
      required String title,
      required String description,
      required String link,
      required Set<String> parents,
      required this.audioCount,
      this.loadedContent = true})
      : super(
            id: id,
            parents: parents,
            title: title,
            description: description,
            sort: sort,
            link: link);

  Section.fromBase(SiteDataBase base,
      {required this.content,
      required this.audioCount,
      this.loadedContent = true})
      : super.copy(base);

  factory Section.fromJson(Map<String, dynamic> json) =>
      _$SectionFromJson(json);
  Map<String, dynamic> toJson() => _$SectionToJson(this);

  @override
  bool operator ==(other) {
    if (other is! Section) {
      return false;
    }

    return id == other.id && title == other.title;
  }

  @override
  int get hashCode => _hashcode ??= [id, title].join('').hashCode;

  Media? getRelativeSibling(Media media, SiblingDirection direction) {
    int indexOfMedia = content
        .indexWhere((element) => element.isMedia && element.id == media.id);

    final siblingOffset = direction == SiblingDirection.next ? 1 : -1;
    final siblingIndex = indexOfMedia + siblingOffset;

    return siblingIndex >= 0 && siblingIndex < content.length
        ? content[siblingIndex].media
        : null;
  }
}

enum SiblingDirection { next, previous }

/// Provides access to site data.
abstract class SiteDataLayer {
  Future<void> init();
  Future<List<Section>> topLevel();
  Future<Section?> section(String id);
  Future<Media?> media(String id);
  Future<List<Media>> recent();

  /// If you don't know what the ID references, this will return first not null of media
  /// or section with given ID.
  Future<SiteDataBase?> mediaOrSection(String id) async =>
      (await media(id)) ?? (await section(id));

  Future<DateTime?> lastUpdate();

  String? getImageFor(String id) => topImagesInside[int.tryParse(id)];
  Future<void> close() async {}
  Future<void> prepareUpdate() async {}
}

/// The entire website. In one object. Ideally, this would only be used server side.
@JsonSerializable()
class SiteData {
  DateTime createdDate;
  final Map<String, Section> sections;
  final Map<String, Media> medias;
  final List<int> topSectionIds;
  final Map<String, List<String>> contentSort;

  SiteData(
      {required this.sections,
      required this.medias,
      required this.contentSort,
      required this.topSectionIds,
      required this.createdDate}) {
    var processing = Map<String, int?>();
    for (final id in sections.keys) {
      _setAudioCount(processing, id, sections);
    }

    /*
     * I think this fixes cases where a main section ends up referncing itself and
     * gets count set to 0?
     * Or it does nothing, and something else fixed the problem I was looking at.
     * Either way, it's easier to leave it then see if it's needed. TODO: that.
     */

    processing.clear();

    for (final id in sections.keys) {
      _setAudioCount(processing, id, sections);
    }
  }

  /// Create site data from list of sections. We support one level of recursion - a section can be in a section,
  /// but no more than that.
  /// This corresponds to a wordpress section, which can be in a category.
  /// But a nested category is only connected to its parent via the childs parent property,
  /// and must be in the first level of [sections].
  SiteData.fromList(
      {required List<Section> sections,
      required List<Media> medias,
      required List<int> topSectionIds,
      required Map<String, List<String>> contentSort,
      required DateTime createdDate})
      : this(
            medias: {
              for (var m in medias) m.id: m
            },
            sections: {
              for (var section in sections
                  .map((e) => [
                        e,
                        ...e.content
                            .where((element) => element.hasSection)
                            .map((e) => e.section!)
                            .toList()
                      ])
                  .expand((element) => element)
                  .toSet())
                section.id: section
            },
            contentSort: contentSort,
            topSectionIds: topSectionIds,
            createdDate: createdDate);

  Map<String, dynamic> toJson() => _$SiteDataToJson(this);

  factory SiteData.fromJson(Map<String, dynamic> json) =>
      _$SiteDataFromJson(json);

  int _setAudioCount(Map<String, int?> processing, String sectionId,
      Map<String, Section> sections) {
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

    final childSections = sections.entries
        .where((element) => element.value.hasParentId(sectionId))
        .toList();

    final childMedia = medias.values
        .where((element) => element.hasParentId(sectionId))
        .toList();

    // Handle empty sections.
    if (childMedia.isEmpty && childSections.isEmpty) {
      processing[sectionId] = section.audioCount = 0;
      return 0;
    }

    // Keep track so that if this section ends up, through its children,
    // referencing itself, we can gracefully return 0.
    processing[sectionId] = null;

    // Count how many classes are directly in this section.
    final directAudioCount = childMedia.length;
    final childSectionAudioCount = childSections.isEmpty
        ? 0
        : childSections
            .map((e) => _setAudioCount(processing, e.key, sections))
            .reduce((value, element) => value + element);

    // Save the audio count.
    processing[sectionId] =
        section.audioCount = directAudioCount + childSectionAudioCount;

    return section.audioCount;
  }
}

/// Provides initial access to load all of site.
/// After the whole site is loaded, it is copied into a data layer.
abstract class SiteDataLoader {
  /// Will load data now if it is readily available.
  /// Must be prepared first by call to [load].
  /// The prepared data will be deleted after retrieved via this method.
  Future<SiteData?> load(DateTime lastLoadTime);
}
