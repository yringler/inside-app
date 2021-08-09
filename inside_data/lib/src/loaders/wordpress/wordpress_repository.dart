import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
import 'package:http/http.dart' as http;

part 'wordpress_repository.g.dart';

class WordpressRepository {
  static const standardApiPath = 'wp-json/wp/v2';
  static const customApiPathCategory = 'wp-json/shiurim/v1';
  static const customApiPathSeries = 'wp-json/shiur-series/v1';
  final String wordpressDomain;
  final wp.WordPress wordPress;

  WordpressRepository({required this.wordpressDomain})
      : wordPress = wp.WordPress(
            baseUrl: wordpressDomain,
            authenticator: wp.WordPressAuthenticator.JWT);

  Future<CustomEndpointCategory> category(int id) async {
    final coreResponse = await http.get(
        Uri.parse('https://$wordpressDomain/$standardApiPath/categories/$id'));
    final category = wp.Category.fromJson(jsonDecode(coreResponse.body));

    return await _childCategories(category);
  }

  Future<CustomEndpointGroup> _series(CustomEndpointPost base) async {
    assert(base.isSeries);
    final id = base.id;

    final postsResponse = await http
        .get(Uri.parse('https://$wordpressDomain/$customApiPathSeries/$id'));
    final posts = (jsonDecode(postsResponse.body) as Map<String, dynamic>)
        .values
        .map((e) => CustomEndpointPost.fromJson(e))
        .toList();

    for (int i = 0; i < posts.length; i++) {
      posts[i].menuOrder = i;
      posts[i].parent = id;
    }

    return CustomEndpointGroup(
        id: base.id,
        name: base.postName,
        description: base.postContentFiltered,
        sort: base.menuOrder ?? 0,
        link: 'https://insidechassidus.org/series/${base.postName}',
        posts: posts);
  }

  Future<CustomEndpointCategory> _childCategories(wp.Category category) async {
    final postsResponse = await http.get(Uri.parse(
        'https://$wordpressDomain/$customApiPathCategory/categories/${category.id ?? 0}'));
    final posts = (jsonDecode(postsResponse.body) as Map<String, dynamic>)
        .values
        .map((e) => CustomEndpointPost.fromJson(e))
        .toList();

    final categories = await wordPress.fetchCategories(
        params: wp.ParamsCategoryList(parent: category.id), fetchAll: true);

    final customCategories =
        (await Future.wait(categories.map((e) => _childCategories(e))))
            .toList();

    for (int i = 0; i < customCategories.length; i++) {
      customCategories[i].sort = i;
    }

    return CustomEndpointCategory(
        id: category.id ?? 0,
        parent: category.parent ?? 0,
        name: category.name ?? '',
        description: category.description ?? '',
        link: category.link ?? '',
        posts: posts.where((element) => element.type == 'post').toList(),
        series: (await Future.wait(
                posts.where((e) => e.type == 'series').map((e) => _series(e))))
            .toList()
              ..forEach((element) => element.parent = category.id ?? 0),
        categories: customCategories);
  }
}

/// Recursively flattens children, does not return self.
/// Returning self would mean that each item would be returned twice - once as a
/// parent, and once as a child.
List<CustomEndpointGroup> flattenCategoryChildren(
        CustomEndpointCategory group) =>
    [
      ...group.series,
      ...[
        for (var group
            in group.categories.map((e) => flattenCategoryChildren(e)))
          ...group
      ]
    ];

/// Used for the core category / series data.
class CustomEndpointGroup {
  final int id;
  final String name;
  final String description;
  late int sort;
  late int parent;
  List<CustomEndpointPost> posts;

  /// A URL to site where this content can be seen.
  final String link;

  CustomEndpointGroup(
      {required this.id,
      required this.name,
      required this.description,
      required this.link,
      this.posts = const []});
}

class CustomEndpointCategory extends CustomEndpointGroup {
  final int parent;
  List<CustomEndpointGroup> series;
  List<CustomEndpointCategory> categories;

  CustomEndpointCategory(
      {required this.parent,
      this.series = const [],
      this.categories = const [],
      List<CustomEndpointPost> posts = const [],
      required int id,
      required String name,
      required String description,
      required String link})
      : super(id: id, name: name, description: description, link: link);
}

/// A post which is returned from the custom categories and series endpoint.
@JsonSerializable(fieldRename: FieldRename.snake)
class CustomEndpointPost {
  final int id;
  int? parent;
  // Will be one of 'post' or 'series'
  final String type;
  final String postTitle;

  /// Used to create URL
  final String postName;
  final String postContentFiltered;
  final String postDate;
  final String postModified;

  /// Where to position this post in list. Only set in category endpoint, not in series endpoint.
  int? menuOrder;

  bool get isPost => type == 'post';
  bool get isSeries => type == 'series';
  DateTime get date => DateTime.parse(postDate);
  DateTime get modified => DateTime.parse(postModified);

  CustomEndpointPost(
      {required this.id,
      required this.postTitle,
      required this.postName,
      required this.postContentFiltered,
      required this.postDate,
      required this.postModified,
      required this.menuOrder,
      required this.type});

  factory CustomEndpointPost.fromJson(Map<String, dynamic> json) =>
      _$CustomEndpointPostFromJson(json);
}
