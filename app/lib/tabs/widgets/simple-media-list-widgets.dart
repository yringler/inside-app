import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/widgets/media-with-context.dart';
import 'package:inside_data/inside_data.dart';

class MediaListTabRoute extends ChangeNotifier implements IRoutDataService {
  Media? media;

  @override
  void setActiveItem(SiteDataBase? data) {
    assert(data is Media);
    this.media = data as Media?;
    notifyListeners();
  }

  bool clear() {
    final hadMedia = hasMedia();
    media = null;

    if (hadMedia) {
      notifyListeners();
    }

    return hadMedia;
  }

  bool hasMedia() => media != null;
}

class MediaListTabNavigator extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> navigatorKey;
  final MediaListTabRoute state;
  final ChosenDataList chosenDataList;

  MediaListTabNavigator(
      {required this.navigatorKey,
      required this.state,
      required this.chosenDataList}) {
    this.state.addListener(notifyListeners);
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          return state.clear();
        },
        pages: [
          MaterialPage(child: chosenDataList),
          if (state.hasMedia())
            MaterialPage(child: PlayerRoute(media: state.media!))
        ],
      );

  @override
  Future<void> setNewRoutePath(configuration) async {}
}

/// A list of media, with navigation to a player.
class MediaListTab extends StatefulWidget {
  final List<ChoosenClass>? data;
  final String emptyMessage;
  final MediaListTabRoute mediaTabRoute;
  final GlobalKey<NavigatorState> navigatorKey;

  MediaListTab(
      {this.data,
      required this.mediaTabRoute,
      required this.emptyMessage,
      required this.navigatorKey});

  @override
  State<StatefulWidget> createState() => MediaListTabState();
}

class MediaListTabState extends State<MediaListTab> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Router(
        backButtonDispatcher: Router.of(context)
            .backButtonDispatcher!
            .createChildBackButtonDispatcher()
          ..takePriority(),
        routerDelegate: MediaListTabNavigator(
            navigatorKey: widget.navigatorKey,
            state: widget.mediaTabRoute,
            chosenDataList: ChosenDataList(
              data: widget.data,
              emptyMessage: widget.emptyMessage,
              routeDataService: widget.mediaTabRoute,
            )),
      ),
    );
  }
}

/// A list of media.
class ChosenDataList extends StatelessWidget {
  final List<ChoosenClass>? data;
  final String emptyMessage;
  final IRoutDataService routeDataService;

  ChosenDataList(
      {this.data, required this.emptyMessage, required this.routeDataService});

  @override
  Widget build(BuildContext context) {
    final data = this.data?.where((element) => element.media != null).toList();

    if (data == null || data.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return Material(
      child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            return MediaWithContext(
              media: item.media!,
              onTap: () => routeDataService.setActiveItem(item.media),
            );
          }),
    );
  }
}
