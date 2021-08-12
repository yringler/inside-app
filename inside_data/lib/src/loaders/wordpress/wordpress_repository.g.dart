// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wordpress_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CustomEndpointGroupToJson(
        CustomEndpointGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sort': instance.sort,
      'posts': instance.posts.map((e) => e.toJson()).toList(),
      'link': instance.link,
    };

CustomEndpointSeries _$CustomEndpointSeriesFromJson(
        Map<String, dynamic> json) =>
    CustomEndpointSeries(
      posts: (json['posts'] as List<dynamic>?)
              ?.map(
                  (e) => CustomEndpointPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      parents:
          (json['parents'] as List<dynamic>?)?.map((e) => e as int).toSet() ??
              {},
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      link: json['link'] as String,
    )..sort = json['sort'] as int;

Map<String, dynamic> _$CustomEndpointSeriesToJson(
        CustomEndpointSeries instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sort': instance.sort,
      'posts': instance.posts.map((e) => e.toJson()).toList(),
      'link': instance.link,
      'parents': instance.parents.toList(),
    };

CustomEndpointCategory _$CustomEndpointCategoryFromJson(
        Map<String, dynamic> json) =>
    CustomEndpointCategory(
      parent: json['parent'] as int,
      series: (json['series'] as List<dynamic>?)
              ?.map((e) =>
                  CustomEndpointSeries.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) =>
                  CustomEndpointCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      posts: (json['posts'] as List<dynamic>?)
              ?.map(
                  (e) => CustomEndpointPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      link: json['link'] as String,
    )..sort = json['sort'] as int;

Map<String, dynamic> _$CustomEndpointCategoryToJson(
        CustomEndpointCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sort': instance.sort,
      'posts': instance.posts.map((e) => e.toJson()).toList(),
      'link': instance.link,
      'parent': instance.parent,
      'series': instance.series.map((e) => e.toJson()).toList(),
      'categories': instance.categories.map((e) => e.toJson()).toList(),
    };

CustomEndpointPost _$CustomEndpointPostFromJson(Map<String, dynamic> json) =>
    CustomEndpointPost(
      parents:
          (json['parents'] as List<dynamic>?)?.map((e) => e as int).toSet() ??
              {},
      id: json['ID'] as int,
      postTitle: json['post_title'] as String,
      postName: json['post_name'] as String,
      postContentFiltered: json['post_content_filtered'] as String,
      postDate: json['post_date'] as String,
      postModified: json['post_modified'] as String,
      menuOrder: json['menu_order'] as int? ?? 0,
      postContent: json['post_content'] as String,
      postType: json['post_type'] as String,
    );

Map<String, dynamic> _$CustomEndpointPostToJson(CustomEndpointPost instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'parents': instance.parents.toList(),
      'post_type': instance.postType,
      'post_title': instance.postTitle,
      'post_name': instance.postName,
      'post_content': instance.postContent,
      'post_content_filtered': instance.postContentFiltered,
      'post_date': instance.postDate,
      'post_modified': instance.postModified,
      'menu_order': instance.menuOrder,
    };
