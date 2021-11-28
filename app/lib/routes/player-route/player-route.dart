import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/routes/player-route/widgets/index.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';

class PlayerRoute extends StatefulWidget {
  static const String routeName = '/library/playerroute';

  final Media media;


  PlayerRoute({required this.media});

  @override
  State<PlayerRoute> createState() => _PlayerRouteState();
}

class _PlayerRouteState extends State<PlayerRoute> {
  final SiteDataLayer _siteBoxes = BlocProvider.getDependency<SiteDataLayer>();

  final libraryPositionService =
      BlocProvider.getDependency<LibraryPositionService>();

  late Media _currMedia;

  @override
  void initState() {
    super.initState();
    _currMedia = widget.media;
  }

  void _changeMedia(Media media) {
    if (mounted)
      setState(() => _currMedia = media);
  }

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
                children: _title(context, _currMedia),
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
                    audioSource: _currMedia.source,
                    downloader: BlocProvider.getDependency<AudioDownloader>(),
                  )
                ],
              ),
            ),
            ProgressBar(
              media: _currMedia,
            ),
            _audioButtonBar()
          ],
        ),
      );

  FutureBuilder<SiteDataBase?> _navigateToLibraryButton() =>
      FutureBuilder<SiteDataBase?>(
        future: _currMedia.getParent(_siteBoxes),
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

  FutureBuilder<Section?> _audioButtonBar() {
    return FutureBuilder<Section?>(
        future: _currMedia.getParent(_siteBoxes),
        builder: (context, snapshot) {
          Media? nextMedia = _currMedia.getRelativeSibling(snapshot.data, 1);
          Media? prevMedia = _currMedia.getRelativeSibling(snapshot.data, -1);

          return AudioButtonBar(
            media: this._currMedia,
            nextMedia: nextMedia,
            onChangedToNextMedia: nextMedia == null ? null :
                () => _changeMedia(nextMedia),
            previousMedia: prevMedia,
            onChangedToPreviousMedia: prevMedia == null ? null :
                () => _changeMedia(prevMedia),
          );
        }
    );
  }

  /// Returns lesson title and media title.
  /// If the media doesn't have a title, just returns lesson title as title.
  List<Widget> _title(BuildContext context, SiteDataBase lesson) {
    if ((_currMedia.title.isNotEmpty) &&
        (lesson.title.isNotEmpty) &&
        _currMedia.title != lesson.title) {
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
          _currMedia.title,
          style: Theme.of(context).textTheme.headline1,
        )
      ];
    }

    return [
      Text(
        _currMedia.title.isNotEmpty ? _currMedia.title : lesson.title,
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
              _currMedia.description,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ),
      );

  Widget _favoriteButton(BuildContext context) {
    final chosenService = BlocProvider.getDependency<ChosenClassService>();

    return chosenService.isFavoriteValueListenableBuilder(
      _currMedia.source,
      builder: (context, isFavorite) => Center(
        child: IconButton(
          iconSize: Theme.of(context).iconTheme.size!,
          onPressed: () =>
              chosenService.set(source: _currMedia, isFavorite: !isFavorite),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
        ),
      ),
    );
  }
}
