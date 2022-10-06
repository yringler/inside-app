import 'dart:convert';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
import 'package:http/http.dart' as http;
import 'package:inside_data/src/loaders/wordpress/wordpress.dart';
import 'package:rxdart/subjects.dart';

import 'custom_wordpress_types.dart';

class WordpressRepository extends Wordpress {
  static const standardApiPath = 'wp-json/wp/v2';
  static const customApiPathCategory = 'wp-json/shiurim/v1';
  static const customApiPathSeries = 'wp-json/shiur-series/v1';
  final wp.WordPress wordPress;
  final Map<int, CustomEndpointGroup> _loadedGroups = {};
  final Map<int, CustomEndpointPost> _loadedPosts = {};

  /// How direct children of a section should be sorted.
  final Map<int, List<int>> contentSort = {};

  Map<int, CustomEndpointGroup> get groups => _loadedGroups;
  Map<int, CustomEndpointPost> get posts => _loadedPosts;

  /// The number of HTTP downloads in progress.
  final BehaviorSubject<int> _connections = BehaviorSubject.seeded(0);

  WordpressRepository({required String wordpressDomain})
      : wordPress = wp.WordPress(
            baseUrl: Wordpress.ensureHttps(wordpressDomain),
            authenticator: wp.WordPressAuthenticator.JWT),
        super(wordpressDomain: wordpressDomain);

  /// Load a category, with all children, recursively.
  Future<void> category(int id) async {
    if (_loadedGroups.containsKey(id)) {
      return;
    }

    final url = '$wordpressDomain/$standardApiPath/categories/$id';
    final coreResponse =
        await _withConnectionCount(() => http.get(Uri.parse(url)), url);

    if (coreResponse == null) {
      return;
    }

    try {
      final category = wp.Category.fromJson(jsonDecode(coreResponse.body));

      _loadedGroups[id] = await _childCategories(category);
    } catch (err) {
      print('Error loading: $url \n $err');
    }

    return;
  }

  /// Load all content of a series-type post.
  Future<CustomEndpointGroup> _series(CustomEndpointPost base) async {
    assert(base.isSeries);
    final id = base.id;

    if (_loadedGroups.containsKey(id)) {
      return _loadedGroups[id]!;
    }

    final url = '$wordpressDomain/$customApiPathSeries/$id';
    final postsResponse =
        await _withConnectionCount(() => http.get(Uri.parse(url)), url);

    Map<String, dynamic>? jsonResponse;

    if (postsResponse != null) {
      try {
        jsonResponse = (jsonDecode(postsResponse.body) as Map<String, dynamic>);
      } catch (err) {
        print('Url: $url\nError: $err');
        //exit(1);
      }
    }

    if (jsonResponse == null) {
      return new CustomEndpointGroup(
          parents: base.parents,
          id: id,
          name: base.postName,
          title: base.postTitle,
          description: base.postContent.isNotEmpty
              ? base.postContent
              : base.postContentFiltered,
          link: '');
    }

    final group = CustomEndpointGroup(
        parents: base.parents,
        id: base.id,
        name: base.postName,
        title: base.postTitle,
        description: base.postContentFiltered,
        link: '$wordpressDomain/series/${base.postName}');

    group.sort = base.menuOrder;

    _loadedGroups[id] = group;

    await _usePosts(jsonResponse, id);
    return group;
  }

  Future<List<CustomEndpointPost>> _usePosts(
      Map<String, dynamic> jsonResponse, int id) async {
    final allPostTypes =
        jsonResponse.values.map((e) => CustomEndpointPost.fromJson(e)).toList();

    final posts = allPostTypes.where((element) => element.isPost).map((e) {
      // To have all parents accounted for, make sure to use saved if found.
      _loadedPosts[e.id] ??= e;
      if (e.menuOrder > 0) {
        _loadedPosts[e.id]!.menuOrder = e.menuOrder;
      }
      _loadedPosts[e.id]!.parents.add(id);
      return _loadedPosts[e.id]!;
    }).toList();

    final series = await Future.wait(allPostTypes
        .where((element) => element.isSeries)
        .map((e) => _series(e))
        .toList());

    for (var s in series) {
      s.parents.add(id);
    }

    contentSort[id] ??= [];
    contentSort[id]!.addAll(posts.map((e) => e.id));
    contentSort[id]!.addAll(series.map((e) => e.id));

    CustomEndpointGroup.setSort(series);

    for (int i = 0; i < allPostTypes.length; i++) {
      var raw = allPostTypes[i];
      if (raw.isPost && raw.menuOrder == 0) {
        posts.firstWhere((element) => element.id == raw.id).menuOrder = i;
      } else if (raw.isSeries && raw.menuOrder == 0) {
        series.firstWhere((element) => element.id == raw.id).sort = i;
      }
    }
    return posts;
  }

  /// Load all child categories' content of category given, recursively. Loads any
  /// series in the category.
  Future<CustomEndpointGroup> _childCategories(wp.Category category) async {
    if (_loadedGroups.containsKey(category.id)) {
      return _loadedGroups[category.id]!;
    }

    final url =
        '$wordpressDomain/$customApiPathCategory/category/${category.id!}';
    final postsResponse =
        await _withConnectionCount(() => http.get(Uri.parse(url)), url);

    if (postsResponse != null && postsResponse.body.trim().isNotEmpty) {
      try {
        await _usePosts(jsonDecode(postsResponse.body), category.id!);
      } catch (err) {
        print('Error querying: $url');
        print(err);
      }
    }

    List<wp.Category>? categories;

    // query for children of category causes error if there aren't any children.
    try {
      categories = await _withConnectionCount(
          () => wordPress.fetchCategories(
              params: wp.ParamsCategoryList(parent: category.id),
              fetchAll: true),
          'Fetch categories with parent: ${category.id}');
    } catch (_) {}

    if (categories != null) {
      // Get child categories. Note that we don't save child category to parent category; that
      // is handled by the child categories parents property.
      // This prevents us from having a data structure with unknown depth.
      final customCategories = (await Future.wait(
              categories.map((e) => _childCategories(e)).toList()))
          .toList();

      contentSort[category.id!] ??= [];
      contentSort[category.id]!.insertAll(0, categories.map((e) => e.id!));

      CustomEndpointGroup.setSort(customCategories);
    }

    final returnValue = CustomEndpointGroup(
        id: category.id ?? 0,
        parents: category.parent != null ? {category.parent!} : {},
        name: category.slug ?? '',
        title: category.name ?? '',
        description: category.description ?? '',
        link: category.link ?? '');

    _loadedGroups[category.id!] = returnValue;

    return returnValue;
  }

  static const int maxConnections = 8;
  Future<T?> _withConnectionCount<T>(
      Future<T> get(), String description) async {
    try {
      while (_connections.value > maxConnections) {
        await _connections.firstWhere((element) => element <= maxConnections);
      }
      _connections.add(_connections.value + 1);

      return await get();
    } catch (err) {
      print('error: $err\nat: $description\n');
    } finally {
      _connections.add(_connections.value - 1);
    }
  }
}
