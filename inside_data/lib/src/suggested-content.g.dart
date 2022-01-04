// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggested-content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimelyContentResponse _$TimelyContentResponseFromJson(
        Map<String, dynamic> json) =>
    _TimelyContentResponse(
      json['parsha'] as int,
    );

Map<String, dynamic> _$TimelyContentResponseToJson(
        _TimelyContentResponse instance) =>
    <String, dynamic>{
      'parsha': instance.parsha,
    };

_DailyClasses _$DailyClassesFromJson(Map<String, dynamic> json) =>
    _DailyClasses(
      json['tanya_id'] as int,
      json['hayom_yom_id'] as int,
    );

Map<String, dynamic> _$DailyClassesToJson(_DailyClasses instance) =>
    <String, dynamic>{
      'tanya_id': instance.tanyaId,
      'hayom_yom_id': instance.hayomYomId,
    };

_Featured _$FeaturedFromJson(Map<String, dynamic> json) => _Featured(
      json['title'] as String,
      json['category'] as int,
      json['imageUrl'] as String,
      json['buttonText'] as String,
    );

Map<String, dynamic> _$FeaturedToJson(_Featured instance) => <String, dynamic>{
      'title': instance.title,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'buttonText': instance.buttonText,
    };

_PopularPost _$PopularPostFromJson(Map<String, dynamic> json) => _PopularPost(
      json['id'] as int,
      _PopularPostContent.fromJson(json['content'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PopularPostToJson(_PopularPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
    };

_PopularPostContent _$PopularPostContentFromJson(Map<String, dynamic> json) =>
    _PopularPostContent(
      json['rendered'] as String,
    );

Map<String, dynamic> _$PopularPostContentToJson(_PopularPostContent instance) =>
    <String, dynamic>{
      'rendered': instance.rendered,
    };
