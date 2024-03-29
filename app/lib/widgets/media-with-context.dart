import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/widgets/media-length.dart';
import 'package:inside_data/inside_data.dart';

/// A tile which shows a media, with parent and grandparent.
class MediaWithContext extends StatelessWidget {
  final Media media;
  final layer = BlocProvider.getDependency<SiteDataLayer>();
  final VoidCallback onTap;

  MediaWithContext({Key? key, required this.media, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<Ancestors>(
        future: _getAncestors(),
        builder: (context, snapshot) {
          var parentTitle = snapshot.data?.parent?.title ?? '';
          var grandParentTitle = snapshot.data?.grandParent?.title ?? '';

          final theme = Theme.of(context);
          final text = theme.textTheme;

          return GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _textDescription(
                            grandParentTitle, text, parentTitle)),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: MediaLength(media: media),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );

  Column _textDescription(
      String grandParentTitle, TextTheme text, String parentTitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text(
            grandParentTitle.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.titleSmall!.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: text.titleSmall!.fontSize! * .9),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 3),
            child: Text(
              parentTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: text.bodyLarge!.fontSize! * 1.1),
            )),
        Text(media.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall!.copyWith(color: Colors.grey.shade600))
      ],
    );
  }

  Future<Ancestors> _getAncestors() async {
    if (!media.hasParent) {
      return Ancestors();
    }

    final parent = await layer.section(media.parents.first);

    if (parent == null || !parent.hasParent) {
      return Ancestors(parent: parent);
    }

    return Ancestors(
      parent: parent,
      grandParent: await layer.section(parent.parents.first),
    );
  }
}

class Ancestors {
  final Section? parent;
  final Section? grandParent;

  Ancestors({this.parent, this.grandParent});
}
