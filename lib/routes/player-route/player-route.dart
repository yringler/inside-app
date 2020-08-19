import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/routes/player-route/widgets/index.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar.dart';

class PlayerRoute extends StatelessWidget {
  static const String routeName = '/library/playerroute';

  final Media media;

  PlayerRoute({this.media});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ..._title(context, media),
            _description(context),
            _favoriteButton(),
            ProgressBar(
              media: media,
            ),
            AudioButtonBar(mediaSource: media.source)
          ],
        ),
      );

  /// Returns lesson title and media title.
  /// If the media doesn't have a title, just returns lesson title as title.
  List<Widget> _title(BuildContext context, SiteDataItem lesson) {
    if ((media.title?.isNotEmpty ?? false) &&
        (lesson?.title?.isNotEmpty ?? false) &&
        media.title != lesson.title) {
      return [
        Container(
          margin: EdgeInsets.only(bottom: 8),
          child: Text(
            lesson.title,
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        Text(
          media.title,
          style: Theme.of(context).textTheme.headline1,
        )
      ];
    }

    return [
      Text(
        media.title?.isNotEmpty ?? false ? media.title : lesson.title,
        style: Theme.of(context).textTheme.headline6,
      )
    ];
  }

  /// Create scrollable description. This is also rendered when
  /// there isn't any description, because it expands and pushes the player
  /// to the bottom of the screen into a consistant location.
  _description(BuildContext context) => Expanded(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              media.description ?? "",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ),
      );

  Widget _favoriteButton() {
    final chosenService = BlocProvider.getDependency<ChosenClassService>();

    return chosenService.isFavoriteValueListenableBuilder(
      media.source,
      builder: (context, isFavorite) => Center(
        child: IconButton(
          onPressed: () => chosenService.set(
              source: media.source,
              sectionId: media.parentId,
              isFavorite: !isFavorite),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
        ),
      ),
    );
  }
}
