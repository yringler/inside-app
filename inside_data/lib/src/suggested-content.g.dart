// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggested-content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuggestedContent _$SuggestedContentFromJson(Map<String, dynamic> json) =>
    SuggestedContent(
      timelyContent: json['timelyContent'] == null
          ? null
          : TimelyContent.fromJson(
              json['timelyContent'] as Map<String, dynamic>),
      popular: (json['popular'] as List<dynamic>?)
          ?.map((e) => ContentReference.fromJson(e as Map<String, dynamic>))
          .toList(),
      featured: (json['featured'] as List<dynamic>?)
          ?.map((e) =>
              FeaturedSectionVerified.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SuggestedContentToJson(SuggestedContent instance) =>
    <String, dynamic>{
      'timelyContent': instance.timelyContent,
      'popular': instance.popular,
      'featured': instance.featured,
    };

TimelyContent _$TimelyContentFromJson(Map<String, dynamic> json) =>
    TimelyContent(
      parsha: json['parsha'] == null
          ? null
          : ContentReference.fromJson(json['parsha'] as Map<String, dynamic>),
      tanya: json['tanya'] == null
          ? null
          : ContentReference.fromJson(json['tanya'] as Map<String, dynamic>),
      hayomYom: json['hayomYom'] == null
          ? null
          : ContentReference.fromJson(json['hayomYom'] as Map<String, dynamic>),
      monthly: json['monthly'] == null
          ? null
          : ContentReference.fromJson(json['monthly'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TimelyContentToJson(TimelyContent instance) =>
    <String, dynamic>{
      'parsha': instance.parsha,
      'tanya': instance.tanya,
      'hayomYom': instance.hayomYom,
      'monthly': instance.monthly,
    };

FeaturedSection _$FeaturedSectionFromJson(Map<String, dynamic> json) =>
    FeaturedSection(
      title: json['title'] as String,
      section: json['section'] == null
          ? null
          : Section.fromJson(json['section'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String,
      buttonText: json['buttonText'] as String,
    );

Map<String, dynamic> _$FeaturedSectionToJson(FeaturedSection instance) =>
    <String, dynamic>{
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'buttonText': instance.buttonText,
      'section': instance.section,
    };

FeaturedSectionVerified _$FeaturedSectionVerifiedFromJson(
        Map<String, dynamic> json) =>
    FeaturedSectionVerified(
      title: json['title'] as String,
      section: Section.fromJson(json['section'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String,
      buttonText: json['buttonText'] as String,
    );

Map<String, dynamic> _$FeaturedSectionVerifiedToJson(
        FeaturedSectionVerified instance) =>
    <String, dynamic>{
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'buttonText': instance.buttonText,
      'section': instance.section,
    };

_TimelyContentResponse _$TimelyContentResponseFromJson(
        Map<String, dynamic> json) =>
    _TimelyContentResponse(
      json['parsha'] as int,
      json['monthly'] as int,
    );

Map<String, dynamic> _$TimelyContentResponseToJson(
        _TimelyContentResponse instance) =>
    <String, dynamic>{
      'parsha': instance.parsha,
      'monthly': instance.monthly,
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
      json['image_url'] as String,
      json['button_text'] as String,
    );

Map<String, dynamic> _$FeaturedToJson(_Featured instance) => <String, dynamic>{
      'title': instance.title,
      'category': instance.category,
      'image_url': instance.imageUrl,
      'button_text': instance.buttonText,
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
