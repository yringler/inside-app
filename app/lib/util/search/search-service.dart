import 'package:inside_data/inside_data.dart';
import 'package:rxdart/rxdart.dart';

//TODO: Overkill?
class SearchService {
  final SiteDataLayer siteBoxes;
  BehaviorSubject<List<ContentReference>> searchResults = BehaviorSubject();
  BehaviorSubject<bool> loading = BehaviorSubject.seeded(false);
  WordpressSearch wordpressSearch = WordpressSearch(wordpressDomain: domain);
  String? term = null;

  SearchService({required this.siteBoxes});

  Future<List<ContentReference>> search(String term) async {
    if (term == this.term) {
      searchResults.add(searchResults.value);
      return Future.value(searchResults.value);
    }

    loading.add(true);
    this.term = term;

    final results = await wordpressSearch.search(term);

    final content =
        (await Future.wait(results.map(_mapSearchResultToContentReference)))
            .where((element) => element != null)
            .map((e) => e!)
            .toList();

    searchResults.add(content);
    loading.add(false);
    return content;
  }

  Future<ContentReference?> _mapSearchResultToContentReference(
      SearchResult result) async {
    SiteDataBase? data;
    if (result.contentType == ContentType.section) {
      data = await siteBoxes.section(result.id);
    } else if (result.contentType == ContentType.media) {
      data = await siteBoxes.media(result.id);
    }
    if (data != null) {
      return ContentReference.fromData(data: data);
    } else {
      return null;
    }
  }
}
