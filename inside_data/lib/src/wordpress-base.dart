import 'package:inside_data/inside_data.dart';
import 'package:inside_data/src/loaders/wordpress/parsing_tools.dart';

abstract class WordpressContent {
  String get postType;

  String get postContentContent;
}

mixin DerivedResultType on WordpressContent {
  ContentType? get type {
    // This happens for results which are tags.
    if (postType.isEmpty) {
      return null;
    }

    if (postType != 'post') {
      return ContentType.section;
    }

    // If it's a post, it might still be a section, if the post contains more than one media.
    final content = parsePost(
        SiteDataBase(
            id: '',
            title: '',
            description: postContentContent,
            sort: 0,
            link: '',
            parents: {}),
        requireAudio: false);

    if (content == null) {
      return null;
    }

    if (content is Media) {
      return ContentType.media;
    }

    return ContentType.section;
  }
}
