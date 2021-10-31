import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/loaders/wordpress/wordpress_repository.dart';

/// Loads site from wordpress REST API.
class WordpressLoader extends SiteDataLoader {
  final String wordpressUrl;
  final WordpressRepository wordpressRepository;
  final List<int> topCategoryIds;

  WordpressLoader({required this.wordpressUrl, required this.topCategoryIds})
      : wordpressRepository =
            WordpressRepository(wordpressDomain: wordpressUrl);

  @override
  Future<SiteData> load(DateTime lastLoadTime,
      {bool ensureLatest = false}) async {
    final data = await Future.wait(
        topCategoryIds.map((e) => wordpressRepository.category(e)).toList());

    return SiteData(topSectionIds: topCategoryIds, sections: [
      ...data.map((e) => e.toSection()),
      ...data.map((e) => e.series).expand((e) => e).map((e) => e.toSection())
    ]);
  }
}
