import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_api/models.dart';
import 'package:inside_api/site-service.dart';
import 'package:inside_chassidus/routes/player-route/widgets/index.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar.dart';
import 'package:just_audio_service/download-manager/download-manager.dart';
import 'package:just_audio_service/widgets/download-button.dart';

class PlayerRoute extends StatelessWidget {
  static const String routeName = '/library/playerroute';

  final Media media;

  final SiteBoxes _siteBoxes = BlocProvider.getDependency<SiteBoxes>();

  final libraryPositionService =
      BlocProvider.getDependency<LibraryPositionService>();

  PlayerRoute({this.media});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _navigateToLibraryButton(),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _title(context, media),
              )),
            ]),
            _description(context),
            Theme(
              data: Theme.of(context).copyWith(
                iconTheme: IconThemeData(size: 30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _favoriteButton(context),
                  DownloadButton(
                    audioUrl: media.source,
                    downloadManager:
                        BlocProvider.getDependency<ForgroundDownloadManager>(),
                  )
                ],
              ),
            ),
            ProgressBar(
              media: media,
            ),
            AudioButtonBar(
              media: media,
            )
          ],
        ),
      );

  FutureBuilder<SiteDataItem> _navigateToLibraryButton() =>
      FutureBuilder<SiteDataItem>(
        future: _getParent(),
        builder: (context, snapshot) => snapshot.data != null
            ? IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.topLeft,
                onPressed: () {
                  libraryPositionService.setActiveItem(snapshot.data);
                },
                icon: Icon(FontAwesomeIcons.chevronDown))
            : Container(),
      );

  Future<SiteDataItem> _getParent() async {
    if (media.sectionId == null) {
      return null;
    }

    final parentSection = await _siteBoxes.sections.get(media.sectionId);

    // Make sure that the parent exists, and that it really has the data.
    // This is done in case IDs change etc - we don't want to navigate to library,
    // to some random place.
    if (parentSection == null ||
        !parentSection.content.any((c) =>
            c?.media == media ||
            (c.mediaSection?.media?.contains(media) ?? false))) {
      return null;
    }

    if (media.sectionId == parentSection.id) {
      return parentSection;
    }

    // If the media is inside a media section

    return parentSection.content
        .firstWhere((content) => content.mediaSection?.id == media.parentId)
        .mediaSection;
  }

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
            textAlign: TextAlign.center,
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

  Widget _favoriteButton(BuildContext context) {
    final chosenService = BlocProvider.getDependency<ChosenClassService>();

    return chosenService.isFavoriteValueListenableBuilder(
      media.source,
      builder: (context, isFavorite) => Center(
        child: IconButton(
          iconSize: Theme.of(context).iconTheme.size,
          onPressed: () =>
              chosenService.set(source: media, isFavorite: !isFavorite),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
        ),
      ),
    );
  }
}
