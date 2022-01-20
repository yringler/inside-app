import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inside_chassidus/routes/player-route/widgets/index.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class-service.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/widgets/media/audio-button-bar.dart';
import 'package:inside_data/inside_data.dart';
import 'package:just_audio_handlers/just_audio_handlers.dart';
import 'package:share_plus/share_plus.dart' as SharePlus;

class PlayerRoute extends StatelessWidget {
  static const String routeName = '/library/playerroute';

  final Media media;
  final SiteDataLayer _siteBoxes = BlocProvider.getDependency<SiteDataLayer>();

  final libraryPositionService =
      BlocProvider.getDependency<LibraryPositionService>();

  final downloader = BlocProvider.getDependency<AudioDownloader>();

  PlayerRoute({required this.media}) : super(key: ValueKey(media.id));

  @override
  Widget build(BuildContext context) => Material(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(children: [
                _navigateToLibraryButton(),
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _favoriteButton(context),
                      DownloadButton(
                        buttonBuilder: (icon, onPressed) => IconButton(
                            tooltip: 'Download class',
                            onPressed: onPressed,
                            icon: Icon(icon)),
                        audioSource: media.source,
                        downloader: downloader,
                      ),
                      if (media.link.isNotEmpty)
                        IconButton(
                            icon: Icon(Icons.share),
                            tooltip: 'Share link',
                            onPressed: () => SharePlus.Share.share(
                                '${_shareText()} ${media.link}',
                                subject: 'Class from Inside Chassidus')),
                      IconButton(
                          icon: Icon(
                            Icons.send_and_archive_outlined,
                            size: 30,
                          ),
                          tooltip: 'Share downloaded file',
                          onPressed: () async {
                            var status = await _tryDownload();

                            // Sometimes download fails. If that happens, try again, but only once.
                            // This should probably be looked into, and fixed in a more central locationl...
                            if (status.status != DownloadTaskStatus.complete) {
                              status = await _tryDownload();
                            }
                            if (status.status != DownloadTaskStatus.complete) {
                              return;
                            }

                            final path =
                                (await downloader.getPlaybackUriFromUri(
                                        Uri.parse(media.source)))
                                    .toFilePath();

                            assert(File(path).existsSync());

                            SharePlus.Share.shareFiles([path],
                                text: _shareText(),
                                subject: 'Class from Inside Chassidus',
                                mimeTypes: path.toLowerCase().endsWith('.mp3')
                                    ? ['audio/mpeg']
                                    : null);
                          })
                    ],
                  ),
                ),
              ),
              ProgressBar(
                media: media,
              ),
              AudioButtonBar.fromMedia(media: media)
            ],
          ),
        ),
      );

  Future<DownloadTask> _tryDownload() async {
    await downloader.downloadFromUri(Uri.parse(media.source));
    final status = await downloader
        .getDownloadStateStream(Uri.parse(media.source))
        .firstWhere((element) => {
              DownloadTaskStatus.failed,
              DownloadTaskStatus.complete
            }.contains(element.status));
    return status;
  }

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
                icon: Icon(Icons.list, size: 50))
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
          tooltip: 'Favorite',
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

  String _shareText() => media.title.isEmpty
      ? 'Listen to this class from Inside Chassidus'
      : media.title;
}
