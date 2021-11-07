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
  Future<SiteData> load(DateTime lastLoadTime,
      {bool ensureLatest = false}) async {
    await Future.wait(
        topCategoryIds.map((e) => wordpressRepository.category(e)).toList());

    final sectionList = [
      ...wordpressRepository.categories.values.map((e) => e.toSection()),
      ...wordpressRepository.groups.values.map((e) => e.toSection()),
    ];

    return SiteData.fromList(
        topSectionIds: topCategoryIds, sections: sectionList);
  }
}
