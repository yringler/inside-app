import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/loaders/wordpress/wordpress_repository.dart';

/// Loads entire site from wordpress REST API.
/// This loader is only intended to be used server side, not client/app side.
/// (Eventually, we may want to implement incremental updates via wordpress REST API,
/// but not for now. That will wait untill we are more confident with the update mechanism.)
class WordpressLoader extends SiteDataLoader {
  final String wordpressUrl;
  final WordpressRepository wordpressRepository;
  final List<int> topCategoryIds;

  WordpressLoader({required this.wordpressUrl, required this.topCategoryIds})
      : wordpressRepository =
            WordpressRepository(wordpressDomain: wordpressUrl);

  /// This load method is only intended to be used server side, and will always load
  /// the entire site.
  /// This may change, see comment on [WordpressLoader].
  @override
  Future<SiteData> initialLoad() async {
    await Future.wait(
        topCategoryIds.map((e) => wordpressRepository.category(e)).toList());

    final postDataBase = wordpressRepository.posts.values
        .map((e) => e.toSiteDataBase())
        .toList();

    final sectionsFromPosts = postDataBase.whereType<Section>().cast<Section>();

    final sectionList = [
      ...wordpressRepository.groups.values.map((e) => e.toSection()),
      ...sectionsFromPosts
    ];

    // If there are multiple posts with identical multiple medias (eg https://insidechassidus.org/basi-ligani-5714/ and https://insidechassidus.org/09-basi-ligani-5714/)
    // ensure that we only have one of each media, and that that media has all parents.
    final nestedMedia = sectionsFromPosts
        .map((e) => e.content)
        .expand((element) => element)
        .where((element) => element.hasMedia)
        .map((e) => e.media!)
        .fold<Map<String, Media>>(Map<String, Media>(),
            (previousValue, element) {
          if (previousValue.containsKey(element.id)) {
            previousValue[element.id]!.parents.addAll(element.parents);
          } else {
            previousValue[element.id] = element;
          }

          return previousValue;
        })
        .values
        .toList();

    return SiteData.fromList(
        medias: [
          ...postDataBase.whereType<Media>().cast<Media>(),
          ...nestedMedia
        ],
        contentSort: {
          for (var kv in wordpressRepository.contentSort.entries)
            kv.key.toString(): kv.value.map((e) => e.toString()).toList(),
          for (var s in sectionsFromPosts)
            s.id: s.content.map((e) => e.id).toList()
        },
        topSectionIds: topCategoryIds,
        // Don't return nested data.
        sections: sectionList
            .map((e) => Section.fromBase(e,
                content: e.content
                    .map((e) => ContentReference.fromId(
                        id: e.id, contentType: e.contentType))
                    .toList(),
                audioCount: e.audioCount))
            .toList(),
        createdDate: DateTime.now());
  }

  /// For now, this loader is only meant to be called server side, and only meant to
  /// load the full site, so only [initialLoad] should be used.
  @override
  Future<SiteData?> load(DateTime lastLoadTime, {bool ensureLatest = false}) {
    throw UnimplementedError();
  }

  @override
  Future<void> prepareUpdate(DateTime lastLoadTime) {
    throw UnimplementedError();
  }
}
