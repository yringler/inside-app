// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wordpress_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResultItem _$SearchResultItemFromJson(Map<String, dynamic> json) =>
    SearchResultItem(
      postType: json['post_type'] as String? ?? '',
      postContent: json['post_content'] as String? ?? '',
      postContentFiltered: json['post_content_filtered'] as String? ?? '',
      id: json['ID'] as int,
    );

Map<String, dynamic> _$SearchResultItemToJson(SearchResultItem instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'post_type': instance.postType,
      'post_content': instance.postContent,
      'post_content_filtered': instance.postContentFiltered,
    };

SearchResponseResult _$SearchResponseResultFromJson(
        Map<String, dynamic> json) =>
    SearchResponseResult(
      source:
          SearchResultItem.fromJson(json['_source'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchResponseResultToJson(
        SearchResponseResult instance) =>
    <String, dynamic>{
      '_source': instance.source,
    };

SearchResponseItem _$SearchResponseItemFromJson(Map<String, dynamic> json) =>
    SearchResponseItem(
      (json['hits'] as List<dynamic>)
          .map((e) => SearchResponseResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchResponseItemToJson(SearchResponseItem instance) =>
    <String, dynamic>{
      'hits': instance.hits,
    };

SearchResponseItemParent _$SearchResponseItemParentFromJson(
        Map<String, dynamic> json) =>
    SearchResponseItemParent(
      hits: SearchResponseItem.fromJson(json['hits'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchResponseItemParentToJson(
        SearchResponseItemParent instance) =>
    <String, dynamic>{
      'hits': instance.hits,
    };

SearchResponseRoot _$SearchResponseRootFromJson(Map<String, dynamic> json) =>
    SearchResponseRoot(
      responses: (json['responses'] as List<dynamic>)
          .map((e) =>
              SearchResponseItemParent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchResponseRootToJson(SearchResponseRoot instance) =>
    <String, dynamic>{
      'responses': instance.responses,
    };
