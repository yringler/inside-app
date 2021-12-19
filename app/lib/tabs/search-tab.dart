import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/routes/search-section-route.dart';
import 'package:inside_chassidus/tabs/widgets/simple-media-list-widgets.dart';
import 'package:inside_data/inside_data.dart';

//TODO: add necessary navigator stuff; see MediaListTabNavigator

class SearchTab extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final MediaListTabRoute routeState;
  final WordpressSearch searchService =
      BlocProvider.getDependency<WordpressSearch>();

  SearchTab({required this.navigatorKey, required this.routeState});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class SearchTabState extends State<SearchTab> {
  GlobalKey<NavigatorState> get navigatorKey => widget.navigatorKey;
  MediaListTabRoute get routeState => widget.routeState;
  WordpressSearch get searchService => widget.searchService;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchService.activeTerm
        .take(1)
        .listen((event) => _controller.text = event);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          return routeState.clear();
        },
        pages: [
          MaterialPage(child: _searchWidget(routeState.hasMedia())),
          if (routeState.hasMedia())
            MaterialPage(child: PlayerRoute(media: routeState.media!))
        ],
      );

  Widget _searchWidget(bool isCoveredByMediaPage) => Container(
        //TODO: Try to bring this in line with padding of other pages
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            _searchInput(isCoveredByMediaPage),
            Expanded(child: _searchResults())
          ],
        ),
      );

  StreamBuilder<List<ContentReference>> _searchResults() {
    return StreamBuilder<List<ContentReference>>(
        stream: searchService.activeResults,
        builder: (context, snapshot) {
          return (!snapshot.hasData
              ? Container()
              : (snapshot.data!.isEmpty
                  ? Center(
                      //TODO: Bring padding in line with other pages
                      child: Text(
                        'No results found. Would you like to search for something else?',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    )
                  : SearchSectionRoute(
                      content: snapshot.data!, routeDataService: routeState)));
        });
  }

  Row _searchInput(bool isCoveredByMediaPage) {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _controller,
          //TODO: Autofocus only when empty or no results? Might not work when navigating back from media screen
          autofocus: !isCoveredByMediaPage,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            hintText: 'Search',
            suffix: StreamBuilder<bool>(
                stream: searchService.isCompleted(_controller.text),
                builder: (context, snapshot) {
                  return snapshot.hasData && snapshot.data!
                      ? Container()
                      : SizedBox(
                          height: 15,
                          width: 15,
                          //TODO: Fix position and/or size. Possibly remove and replace with another loader elsewhere.
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        );
                }),
          ),
          onSubmitted: (value) => searchService.search(value),
        )),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            FocusScope.of(context).unfocus();
            searchService.search(_controller.value.text);
          },
        )
      ],
    );
  }
}
