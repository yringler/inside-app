import 'dart:convert';
import 'dart:io';

import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/loaders/wordpress/parsing_tools.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';

part 'wordpress_repository.g.dart';

class WordpressRepository {
  static const standardApiPath = 'wp-json/wp/v2';
  static const customApiPathCategory = 'wp-json/shiurim/v1';
  static const customApiPathSeries = 'wp-json/shiur-series/v1';
  final String wordpressDomain;
  final wp.WordPress wordPress;
  final Map<int, CustomEndpointCategory> _loadedCategories = {};
  final Map<int, CustomEndpointGroup> _loadedGroups = {};
  final Map<int, CustomEndpointPost> _loadedPosts = {};

  Map<int, CustomEndpointCategory> get categories => _loadedCategories;
  Map<int, CustomEndpointGroup> get groups => _loadedGroups;
  Map<int, CustomEndpointPost> get posts => _loadedPosts;

  /// The number of HTTP downloads in progress.
  final BehaviorSubject<int> _connections = BehaviorSubject.seeded(0);

  WordpressRepository({required this.wordpressDomain})
      : wordPress = wp.WordPress(
            baseUrl: wordpressDomain.contains('http')
                ? wordpressDomain
                : 'https://$wordpressDomain',
            authenticator: wp.WordPressAuthenticator.JWT);

  /// Load a category, with all children, recursively.
  Future<void> category(int id) async {
    if (_loadedCategories.containsKey(id)) {
      return;
    }

    final coreResponse = await _withConnectionCount(() => http.get(
        Uri.parse('https://$wordpressDomain/$standardApiPath/categories/$id')));
    final category = wp.Category.fromJson(jsonDecode(coreResponse.body));

    _loadedCategories[id] = await _childCategories(category);
    return;
  }

  /// Load all content of a series-type post.
  Future<CustomEndpointSeries> _series(CustomEndpointPost base) async {
    assert(base.isSeries);
    final id = base.id;

    if (_loadedGroups.containsKey(id)) {
      return _loadedGroups[id]! as CustomEndpointSeries;
    }

    final url = 'https://$wordpressDomain/$customApiPathSeries/$id';
    print(url);
    final postsResponse =
        await _withConnectionCount(() => http.get(Uri.parse(url)));

    Map<String, dynamic>? jsonResponse;

    try {
      jsonResponse = (jsonDecode(postsResponse.body) as Map<String, dynamic>);
    } catch (err) {
      print('Url: $url\nError: $err');
      //exit(1);
    }

    if (jsonResponse == null) {
      return new CustomEndpointSeries(
          parents: base.parents,
          id: id,
          name: base.postName,
          title: base.postTitle,
          description: base.postContent.isNotEmpty
              ? base.postContent
              : base.postContentFiltered,
          link: '');
    }

    final posts =
        jsonResponse.values.map((e) => CustomEndpointPost.fromJson(e)).map((e) {
      // To have all parents accounted for, make sure to use saved if found.
      _loadedPosts[e.id] ??= e;
      if (e.menuOrder > 0) {
        _loadedPosts[e.id]!.menuOrder = e.menuOrder;
      }
      _loadedPosts[e.id]!.parents.add(id);
      return _loadedPosts[e.id]!;
    }).toList();

    for (int i = 0; i < posts.length; i++) {
      if (posts[i].menuOrder == 0) {
        posts[i].menuOrder = i;
      }
    }

    final group = CustomEndpointSeries(
        parents: base.parents,
        id: base.id,
        name: base.postName,
        title: base.postTitle,
        description: base.postContentFiltered,
        link: 'https://$wordpressDomain/series/${base.postName}',
        posts: posts);

    group.sort = base.menuOrder;

    _loadedGroups[id] = group;
    return group;
  }

  /// Load all child categories' content of category given, recursively. Loads any
  /// series in the category.
  Future<CustomEndpointCategory> _childCategories(wp.Category category) async {
    if (_loadedCategories.containsKey(category.id)) {
      return _loadedCategories[category.id]!;
    }

    final postsResponse = await _withConnectionCount(() => http.get(Uri.parse(
        'https://$wordpressDomain/$customApiPathCategory/category/${category.id!}')));

    List<CustomEndpointPost>? posts;

    if (postsResponse.body.trim().isNotEmpty) {
      posts = (jsonDecode(postsResponse.body) as Map<String, dynamic>)
          .values
          .map((e) => CustomEndpointPost.fromJson(e))
          .map((e) {
        // To have all parents accounted for, make sure to use saved if found.
        _loadedPosts[e.id] ??= e;
        if (e.menuOrder > 0) {
          _loadedPosts[e.id]!.menuOrder = e.menuOrder;
        }
        if (category.id != null) {
          _loadedPosts[e.id]!.parents.add(category.id!);
        }
        return _loadedPosts[e.id]!;
      }).toList();
    }

    final categories = await _withConnectionCount(() =>
        wordPress.fetchCategories(
            params: wp.ParamsCategoryList(parent: category.id),
            fetchAll: true));

    // Get child categories. Note that we don't save child category to parent category; that
    // is handled by the child categories parents property.
    // This prevents us from having a data structure with unknown depth.
    final customCategories =
        (await Future.wait(categories.map((e) => _childCategories(e)).toList()))
            .toList();

    CustomEndpointGroup.setSort(customCategories);

    List<CustomEndpointSeries> series = posts != null
        ? (await Future.wait(
                posts.where((e) => e.isSeries).map((e) => _series(e)).toList()))
            .toList()
        : [];

    if (category.id != null) {
      series.forEach((element) => element.parents.add(category.id!));
    }

    CustomEndpointGroup.setSort(series);

    final returnValue = CustomEndpointCategory(
        id: category.id ?? 0,
        parents: category.parent != null ? {category.parent!} : {},
        name: category.slug ?? '',
        title: category.name ?? '',
        description: category.description ?? '',
        link: category.link ?? '',
        posts: posts?.where((element) => element.isPost).toList() ?? [],
        series: series);

    _loadedCategories[category.id!] = returnValue;

    return returnValue;
  }

  Future<T> _withConnectionCount<T>(Future<T> get()) async {
    try {
      await _connections.firstWhere((element) => element < 10);
      _connections.add(_connections.value + 1);
      return await get();
    } catch (err) {
      print('error: $err');
      throw err;
    } finally {
      _connections.add(_connections.value - 1);
    }
  }
}

/// Used for the core category / series data.
@JsonSerializable(
    fieldRename: FieldRename.snake, explicitToJson: true, createFactory: false)
abstract class CustomEndpointGroup {
  final int id;

  /// This is parents, but not from json.
  @JsonKey(defaultValue: {})
  final Set<int> parents;

  /// Should be called slug - this might be because of JSON requirments, but even
  /// then we can always rename it.
  final String name;

  /// Human readable title.
  final String title;
  final String description;
  int sort = 0;
  List<CustomEndpointPost> posts;

  /// A URL to site where this content can be seen.
  final String link;

  CustomEndpointGroup(
      {required this.id,
      required this.name,
      required this.title,
      required this.description,
      required this.link,
      required this.parents,
      this.posts = const []});

  CustomEndpointGroup.copy(CustomEndpointGroup other)
      : this(
            id: other.id,
            name: other.name,
            title: other.title,
            description: other.description,
            link: other.link,
            parents: other.parents);

  Map<String, dynamic> toJson() => _$CustomEndpointGroupToJson(this);

  static void setSort(List<CustomEndpointGroup> groups) {
    for (int i = 0; i < groups.length; ++i) {
      groups[i].sort = i + 1;
    }
  }

  Section toSection() {
    final base = parsePost(SiteDataBase(
        parents: parents.map((e) => e.toString()).toSet(),
        id: id.toString(),
        title: title,
        description: description,
        sort: sort,
        link: link));

    if (base == null) {
      throw "to section parse post: returned null";
    }

    final sectionContent = posts
        .map((e) => parsePost(SiteDataBase(
            id: id.toString(),
            title: title,
            description: description,
            sort: sort,
            link: link,
            parents: parents.map((e) => e.toString()).toSet())))
        .where((element) => element != null)
        .cast<SiteDataBase>()
        .map((e) => ContentReference.fromData(data: e))
        .toList();

    return Section.fromBase(base, content: sectionContent);
  }
}

/// A series is a custom post type which can be a parent to other posts.
/// Sqlite-wise, it will end up being stored as a post, not a section.
/// This class could probably be deleted at this point (now that the parents property
/// was moved up to parent).
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CustomEndpointSeries extends CustomEndpointGroup {
  CustomEndpointSeries(
      {List<CustomEndpointPost> posts = const [],
      required Set<int> parents,
      required int id,
      required String name,
      required String title,
      required String description,
      required String link})
      : super(
            id: id,
            name: name,
            title: title,
            parents: parents,
            description: description,
            link: link,
            posts: posts);

  factory CustomEndpointSeries.fromJson(Map<String, dynamic> json) =>
      _$CustomEndpointSeriesFromJson(json);
  Map<String, dynamic> toJson() => _$CustomEndpointSeriesToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CustomEndpointCategory extends CustomEndpointGroup {
  List<CustomEndpointSeries> series;

  CustomEndpointCategory(
      {this.series = const [],
      List<CustomEndpointPost> posts = const [],
      required int id,
      required Set<int> parents,
      required String name,
      required String title,
      required String description,
      required String link})
      : super(
            id: id,
            name: name,
            title: title,
            parents: parents,
            description: description,
            link: link,
            posts: posts);

  CustomEndpointCategory.withBase(CustomEndpointGroup group,
      {required this.series})
      : super.copy(group);

  factory CustomEndpointCategory.fromJson(Map<String, dynamic> json) =>
      _$CustomEndpointCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CustomEndpointCategoryToJson(this);

  Section toSection() {
    // This takes care of basic properties
    final base = super.toSection();

    return Section.fromBase(base,
        content: series
            .map((e) => e.toSection())
            .map((e) => ContentReference.fromData(data: e))
            .toList());
  }
}

/// A post which is returned from the custom categories and series endpoint.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CustomEndpointPost {
  @JsonKey(name: 'ID')
  final int id;
  @JsonKey(defaultValue: {})
  final Set<int> parents;
  // Will be one of 'post' or 'series'
  final String postType;
  final String postTitle;
  final String guid;

  /// Used to create URL
  final String postName;
  final String postContent;
  final String postContentFiltered;
  final String postDate;
  final String postModified;

  /// Where to position this post in list. Only set in category endpoint, not in series endpoint.
  @JsonKey(defaultValue: 0)
  int menuOrder;

  bool get isPost => postType == 'post';
  bool get isSeries => postType == 'series';
  DateTime get date => DateTime.parse(postDate);
  DateTime get modified => DateTime.parse(postModified);

  CustomEndpointPost(
      {required this.parents,
      required this.id,
      required this.postTitle,
      required this.postName,
      required this.postContentFiltered,
      required this.postDate,
      required this.postModified,
      required this.menuOrder,
      required this.postContent,
      required this.postType,
      required this.guid});

  factory CustomEndpointPost.fromJson(Map<String, dynamic> json) =>
      _$CustomEndpointPostFromJson(json);
  Map<String, dynamic> toJson() => _$CustomEndpointPostToJson(this);

  SiteDataBase? toSiteDataBase() {
    final domain = Uri.parse(guid).host;
    final pathPrefix = this.isSeries ? 'series/' : '';
    final url = 'https://$domain/$pathPrefix$postName';
    final base = parsePost(SiteDataBase(
        parents: parents.map((e) => e.toString()).toSet(),
        id: id.toString(),
        title: postTitle,
        description: postContent.isNotEmpty ? postContent : postContentFiltered,
        sort: menuOrder,
        link: url));

    return base;
  }
}
