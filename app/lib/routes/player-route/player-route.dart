import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/routes/player-route/widgets/index.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar.dart';
import 'package:inside_data/inside_data.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';

class PlayerRoute extends StatelessWidget {
  static const String routeName = '/library/playerroute';

  final Media media;
  final SiteDataLayer _siteBoxes = BlocProvider.getDependency<SiteDataLayer>();

  final libraryPositionService =
      BlocProvider.getDependency<LibraryPositionService>();

  PlayerRoute({required this.media});

  @override
  Widget build(BuildContext context) => Material(
        child: Container(
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
                      buttonBuilder: (icon, onPressed) => IconButton(
                          onPressed: onPressed,
                          icon: Icon(
                            icon,
                          )),
                      audioSource: media.source,
                      downloader: BlocProvider.getDependency<AudioDownloader>(),
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
        ),
      );

  FutureBuilder<SiteDataBase?> _navigateToLibraryButton() =>
      FutureBuilder<SiteDataBase?>(
        future: media.getParent(_siteBoxes),
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

  /// Returns lesson title and media title.
  /// If the media doesn't have a title, just returns lesson title as title.
  List<Widget> _title(BuildContext context, SiteDataBase lesson) {
    if ((media.title.isNotEmpty) &&
        (lesson.title.isNotEmpty) &&
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
        media.title.isNotEmpty ? media.title : lesson.title,
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
              media.description,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ),
      );

  Widget _favoriteButton(BuildContext context) {
    final chosenService = BlocProvider.getDependency<ChosenClassService>();

    return chosenService.isFavoriteValueListenableBuilder(
      media.id,
      builder: (context, isFavorite) => Center(
        child: IconButton(
          iconSize: Theme.of(context).iconTheme.size!,
          onPressed: () =>
              chosenService.set(media: media, isFavorite: !isFavorite),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
        ),
      ),
    );
  }
}
