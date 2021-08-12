import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:html_unescape/html_unescape_small.dart';

import 'package:inside_data/inside_data.dart';

final htmlUnescape = HtmlUnescape();

void parseDataXml(SiteDataBase dataItem) {
  dataItem.title = _parseXml(dataItem.title);
  dataItem.description = _parseXml(dataItem.description);
}

String _parseXml(String xmlString) {
  final xml = html.parse(xmlString.replaceAll('<br>', '\n'));
  final returnValue = xml.children.map((e) => e.text).join(' ').trim();

  return returnValue.isEmpty ? '' : htmlUnescape.convert(returnValue);
}

/// Turns a post... possibly into a section, if it contains multiple media items.
SiteDataBase? parsePost(SiteDataBase post) {
  final xml = html.parse(post.description);

  final audios = xml.querySelectorAll('.wp-block-audio');

  for (final audio in audios) {
    audio.remove();
  }

  if (audios.isEmpty) {
    return null;
  }

  var description = _parseXml(xml.outerHtml);

  // If it doesn't have a good description, forget about it.
  // In particular, sometimes the description will be "MP3"
  if (description.length < 4) {
    description = '';
  }

  if (audios.length == 1) {
    final media = _toMedia(audios.first,
        description: description,
        title: post.title,
        order: post.sort,
        link: post.link,
        id: post.id)
      ?..parent = post.parent;

    return media;
  }

  int sort = 0;
  final medias = audios
      .map((e) => _toMedia(e,
          description: '',
          title: '',
          // Oooh sneaky. I haven't done a sneaky post fix increment like that
          // ... ever, I think.
          order: sort++,
          link: post.link)
        ?..parent = int.parse(post.id))
      .where((element) => element != null)
      .cast<Media>()
      .toList();

  // Give any media without a good title the title of the post with a counter.
  for (var i = 0; i < medias.length; ++i) {
    if ((medias[i].title.length) <= 3) {
      String title = '';

      if (post.title.length > 3) {
        title += '${post.title}: ';
      }

      medias[i].title = title + 'Class ${i + 1}';
    }
  }

  if (medias.isEmpty) {
    return null;
  }

  return Section(
      id: post.id,
      link: post.link,
      title: post.title,
      description: description,
      content: medias.map((e) => ContentReference(media: e)).toList(),
      sort: post.sort)
    ..parent = post.parent;
}

Media? _toMedia(Element element,
    {required String description,
    required String title,
    required int order,
    required String link,
    String? id}) {
  final audioSource = element.querySelector('audio')?.attributes['src'];
  final audioTitle = title.isNotEmpty
      ? title
      : element.querySelector('figcaption')?.text.trim();

  if (audioSource?.isEmpty ?? true) {
    return null;
  }

  return Media(
      id: id ?? audioSource!,
      link: link,
      source: audioSource!,
      title: audioTitle ?? '',
      description: description,
      sort: order);
}
