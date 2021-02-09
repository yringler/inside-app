import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/util/chosen-classes/chosen-class.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';

class MediaListTabRoute extends ChangeNotifier implements IRoutDataService {
  Media media;

  @override
  setActiveItem(SiteDataItem data) {
    assert(data is Media);
    this.media = media;
    notifyListeners();
  }

  clear() {
    final hadMedia = hasMedia();
    media = null;

    if (hadMedia) {
      notifyListeners();
    }

    return hadMedia;
  }

  hasMedia() => media != null;
}

class MediaListTabNavigator extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> navigatorKey;
  final MediaListTabRoute state;
  final ChosenDataList chosenDataList;

  MediaListTabNavigator(
      {@required this.navigatorKey,
      @required this.state,
      @required this.chosenDataList}) {
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
            MaterialPage(child: PlayerRoute(media: state.media))
        ],
      );

  @override
  Future<void> setNewRoutePath(configuration) async {}
}

/// A list of media, with navigation to a player.
class MediaListTab extends StatefulWidget {
  final List<ChoosenClass> data;
  final String emptyMessage;
  final MediaListTabRoute mediaTabRoute = MediaListTabRoute();
  final navigatorKey = GlobalKey();

  MediaListTab({this.data, @required this.emptyMessage});

  @override
  State<StatefulWidget> createState() => MediaListTabState();
}

class MediaListTabState extends State<MediaListTab> {
  @override
  Widget build(BuildContext context) => BlocProvider(
      dependencies: [Dependency<IRoutDataService>((i) => widget.mediaTabRoute)],
      child: Router(
        backButtonDispatcher: Router.of(context)
            .backButtonDispatcher
            .createChildBackButtonDispatcher()
              ..takePriority(),
        routerDelegate: MediaListTabNavigator(
            navigatorKey: widget.navigatorKey,
            state: widget.mediaTabRoute,
            chosenDataList: ChosenDataList(
              data: widget.data,
              emptyMessage: widget.emptyMessage,
            )),
      ));
}

/// A list of media.
class ChosenDataList extends StatelessWidget {
  final List<ChoosenClass> data;
  final String emptyMessage;

  ChosenDataList({this.data, @required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }

    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];

          return ListTile(
            title: Text(item.media.title),
            subtitle: item.media.description != null
                ? Text(
                    item.media.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            onTap: () {
              BlocProvider.getDependency<IRoutDataService>()
                  .setActiveItem(item.media);
            },
          );
        });
  }
}
