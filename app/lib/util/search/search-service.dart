import 'package:inside_data_flutter/inside_data_flutter.dart';
import 'package:rxdart/rxdart.dart';

//TODO: Overkill?
class SearchService {
  final SiteDataLayer siteBoxes;
  //TODO: Remove nullability?
  BehaviorSubject<List<ContentReference>> searchResults = BehaviorSubject();
  WordpressSearch wordpressSearch = WordpressSearch(wordpressDomain: domain);
  //TODO: Update to BehaviorSubject
  bool loading = false;
  String? term = null;

  SearchService({required this.siteBoxes});

  Future<List<ContentReference>> search(String term) async {
    if (term == this.term)
      return Future.value(searchResults.value);

    this.term = term;

    final results = await wordpressSearch.search(term);

    final content = (await Future.wait(results
          .map(_mapSearchResultToContentReference)))
      .where((element) => element != null)
      .map((e) => e!)
      .toList();

    searchResults.add(content);
    return content;
  }


  Future<ContentReference?> _mapSearchResultToContentReference(SearchResult result) async {
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