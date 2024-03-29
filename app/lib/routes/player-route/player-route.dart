import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
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
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: _navigateToLibraryButton(),
                ),
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
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _favoriteButton(context),
                      StreamBuilder<DownloadTaskStatus>(
                          stream: downloader
                              .getDownloadStateStream(
                                  Uri.parse(media.mediaSource))
                              .map((event) => event.status),
                          initialData: DownloadTaskStatus.undefined,
                          builder: (context, snapshot) {
                            return _labeledWidget(
                              context: context,
                              label:
                                  snapshot.data! == DownloadTaskStatus.complete
                                      ? 'Delete'
                                      : 'Download',
                              child: DownloadButton(
                                buttonBuilder: (icon, onPressed) =>
                                    ShrunkIconButton(
                                        tooltip: 'Download class',
                                        onPressed: onPressed,
                                        icon: Icon(icon)),
                                audioSource: media.mediaSource,
                                downloader: downloader,
                              ),
                            );
                          }),
                      _labeledWidget(
                        context: context,
                        label: 'Share',
                        child: ShrunkIconButton(
                            icon: Icon(Icons.share),
                            tooltip: 'Share link',
                            onPressed: () => _openShareModal(context)),
                      ),
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
    await downloader.downloadFromUri(Uri.parse(media.mediaSource));
    final status = await downloader
        .getDownloadStateStream(Uri.parse(media.mediaSource))
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
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          media.title,
          style: Theme.of(context).textTheme.displayLarge,
        )
      ];
    }

    return [
      Text(
        media.title.isNotEmpty ? media.title : lesson.title,
        style: Theme.of(context).textTheme.titleLarge,
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );

  Widget _favoriteButton(BuildContext context) {
    final chosenService = BlocProvider.getDependency<ChosenClassService>();

    return chosenService.isFavoriteValueListenableBuilder(
      media.id,
      builder: (context, isFavorite) => _labeledWidget(
          context: context,
          child: ShrunkIconButton(
            tooltip: 'Favorite',
            onPressed: () =>
                chosenService.set(media: media, isFavorite: !isFavorite),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
          label: 'Favorite'),
    );
  }

  Widget _labeledWidget(
          {required BuildContext context,
          required Widget child,
          required String label}) =>
      Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: child,
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
      );

  String _shareText() => media.title.isEmpty
      ? 'Listen to this class from Inside Chassidus'
      : media.title;

  Future<void> _openShareModal(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (media.link.isNotEmpty) ...[
                _shareRow(
                    context: context,
                    icon: Icons.link,
                    onPressed: () => SharePlus.Share.share(
                        '${_shareText()} ${media.link}',
                        subject: 'Class from Inside Chassidus'),
                    description: 'Share a link to listen to this class online'),
                Divider()
              ],
              StreamBuilder<DownloadTask>(
                  stream: downloader
                      .getDownloadStateStream(Uri.parse(media.mediaSource)),
                  builder: (context, snapshot) {
                    return _shareRow(
                        context: context,
                        icon: Icons.file_upload,
                        onPressed: _shareFile,
                        description: snapshot.hasData &&
                                snapshot.data!.status ==
                                    DownloadTaskStatus.complete
                            ? 'Share the downloaded class'
                            : 'Download the class and then share it');
                  })
            ],
          ),
        ),
      ),
    );
  }

  Row _shareRow(
      {required VoidCallback onPressed,
      required IconData icon,
      required String description,
      required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: onPressed, icon: Icon(icon)),
        Expanded(
          child: GestureDetector(
              onTap: onPressed,
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              )),
        )
      ],
    );
  }

  Future<void> _shareFile() async {
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
        (await downloader.getPlaybackUriFromUri(Uri.parse(media.mediaSource)))
            .toFilePath();

    assert(File(path).existsSync());

    SharePlus.Share.shareFiles([path],
        text: _shareText(),
        subject: 'Class from Inside Chassidus',
        mimeTypes: path.toLowerCase().endsWith('.mp3') ? ['audio/mpeg'] : null);
  }
}

class ShrunkIconButton extends IconButton {
  ShrunkIconButton(
      {required String tooltip,
      required Widget icon,
      required VoidCallback onPressed})
      : super(
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: icon,
            onPressed: onPressed,
            tooltip: tooltip);
}
