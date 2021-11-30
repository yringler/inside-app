import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
//TODO: When do we import index vs file itself
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/routes/search-section-route.dart';
import 'package:inside_chassidus/tabs/widgets/simple-media-list-widgets.dart';
import 'package:inside_chassidus/util/search/search-service.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';

//TODO: Break this down into smaller widgets and add necessary navigator stuff; see MediaListTabNavigator
class SearchTab extends StatefulWidget  {
  final GlobalKey<NavigatorState> navigatorKey;
  final MediaListTabRoute routeState;

  SearchTab({required this.navigatorKey, required this.routeState});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final searchService = BlocProvider.getDependency<SearchService>();
  TextEditingController _controller = TextEditingController();


  @override
  void initState() {
    super.initState();

    if (searchService.term != null) {
      _controller.text = searchService.term!;
      // if (!widget.routeState.hasMedia()) {
      //   _controller.selection = TextSelection(baseOffset: 0, extentOffset: searchService.term!.length);
      // }
    }
  }

  @override
  Widget build(BuildContext context) => Navigator(
    key: widget.navigatorKey,
    onPopPage: (route, result) {
      if (!route.didPop(result)) {
        return false;
      }

      return widget.routeState.clear();
    },
    pages: [
      MaterialPage(child: _getSearch(widget.routeState.hasMedia())),
      if (widget.routeState.hasMedia())
        MaterialPage(child: PlayerRoute(media: widget.routeState.media!))
    ],
  );

  Widget _getSearch(bool isCoveredByMediaPage) => Container(
    //TODO: Try to bring this in line with padding of other pages
    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              //TODO: Do we want to search automatically, perhaps with a debounce?
                child: TextField(
                  controller: _controller,
                  //TODO: Autofocus only when empty or no results? Might not work when navigating back from media screen
                  autofocus: !hasMedia,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      hintText: 'Search',
                      suffix: StreamBuilder<bool>(
                        stream: searchService.loading.stream,
                        builder: (context, snapshot) {
                          return snapshot.hasData && snapshot.data!
                              ? SizedBox(
                                height: 15,
                                width: 15,
                                //TODO: Fix position and/or size. Possibly remove and replace with another loader elsewhere.
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              )
                              : SizedBox.shrink();
                        }
                      ),
                  ),
                  onSubmitted: (value) => searchService.search(value),
                )
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                FocusScope.of(context).unfocus();
                searchService.search(_controller.value.text);
              },
            )
          ],
        ),
        Expanded(
            child: StreamBuilder<List<ContentReference>>(
              stream: searchService.searchResults.stream,
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
                          content: snapshot.data!,
                          routeDataService: widget.routeState
                      )
                  )
                );
              }
            )
        )
      ],
    ),
  );
}
