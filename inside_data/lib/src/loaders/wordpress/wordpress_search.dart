import 'dart:convert';
import 'package:inside_data/inside_data.dart';
import 'package:http/http.dart' as http;
import 'package:inside_data/src/loaders/wordpress/custom_wordpress_types.dart';
import 'package:inside_data/src/loaders/wordpress/wordpress.dart';

class WordpressSearch extends Wordpress {
  static const searchApiPath =
      'wp-content/plugins/elasticpress-custom/proxy/proxy.php';

  WordpressSearch({required String wordpressDomain})
      : super(wordpressDomain: wordpressDomain);

  Future<List<SearchResult>> search(String term) async {
    final resultResponse = await _fetchSearchResults(term);

    final searchResults = <SearchResult>[];
    //TODO: Create Classes for the below or use the flutter elastic library
    for (var response in resultResponse["responses"]) {
      for (var hit in response["hits"]["hits"]) {
        final source = hit["_source"];
        //TODO: What about tags or other possible results?
        if (source["post_type"] == "series" || source["post_type"] == "post") {
          final result =
              SearchResult._fromPost(CustomEndpointPost.fromJson(source));
          searchResults.add(result);
        }
      }
    }
    return searchResults;
  }

  Future<Map<String, dynamic>> _fetchSearchResults(String term) async {
    final url = '$wordpressDomain/$searchApiPath?term=$term';
    final coreResponse = await http.get(Uri.parse(url));

    //TODO: We don't check this elsewhere, is that for a reason?
    if (coreResponse.statusCode == 200) {
      return jsonDecode(coreResponse.body);
    } else {
      //TODO: Deal with error here? Put in try catch as well?
      return Future.error(coreResponse);
    }
  }
}

class SearchResult {
  final String id;
  final ContentType contentType;

  SearchResult({required this.id, required this.contentType});

  factory SearchResult._fromPost(CustomEndpointPost post) => SearchResult(
      id: post.id.toString(),
      //TODO: Account for neither post nor series?
      contentType: post.isPost ? ContentType.media : ContentType.section);
}
