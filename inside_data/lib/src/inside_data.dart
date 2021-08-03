class SiteDataBase {
  final String id;
  final String title;
  final String description;

  SiteDataBase(
      {required this.id, required this.title, required this.description});
}

class Media extends SiteDataBase {
  final String source;
  final Duration length;

  Media(
      {required this.source,
      required this.length,
      required String id,
      required String title,
      required String description})
      : super(id: id, title: title, description: description);
}

/// Holds one of [Media] or [Section]. Has a value method which is the non null value.
class ContentReference {
  final Media? media;
  final Section? section;
  final SiteDataBase value;

  ContentReference({this.media, this.section}) : value = (media ?? section)! {
    // 1 and only 1 must be not null.
    assert((media ?? section) != null);
    assert(media == null || section == null);
  }

  bool get isMedia => media != null;
  bool get isSection => section != null;
}

class Section extends SiteDataBase {
  final int audioCount;
  final List<ContentReference> content;

  Section(
      {required this.audioCount,
      required this.content,
      required String id,
      required String title,
      required String description})
      : super(id: id, title: title, description: description);
}

/// Provides access to site data.
abstract class SiteDataLayer {
  Future<void> init();
  List<Section> topLevel();
  Future<Section> parentOf(SiteDataBase);
}
