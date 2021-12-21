import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/routes/search-section-route.dart';
import 'package:inside_chassidus/tabs/widgets/simple-media-list-widgets.dart';
import 'package:inside_data/inside_data.dart';
import 'package:rxdart/subjects.dart';

//TODO: add necessary navigator stuff; see MediaListTabNavigator

class SearchTab extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final MediaListTabRoute routeState;
  final WordpressSearch searchService =
      BlocProvider.getDependency<WordpressSearch>();

  SearchTab({required this.navigatorKey, required this.routeState});

  @override
  State<StatefulWidget> createState() => SearchTabState();
}

class SearchTabState extends State<SearchTab> {
  GlobalKey<NavigatorState> get navigatorKey => widget.navigatorKey;
  MediaListTabRoute get routeState => widget.routeState;
  WordpressSearch get searchService => widget.searchService;
  final BehaviorSubject<bool> _hasFocus = BehaviorSubject.seeded(false);

  late FocusNode _searchFocus;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchFocus = FocusNode();
    _searchFocus.addListener(() => _hasFocus.add(_searchFocus.hasPrimaryFocus));

    if (searchService.activeTerm.isNotEmpty) {
      _controller.text = searchService.activeTerm;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocus.dispose();
    _hasFocus.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          // If the input has focus and user clicks back, remove focus.
          // if (_searchFocus.hasPrimaryFocus) {
          //   _searchFocus.unfocus();
          //   return false;
          // }

          return routeState.clear();
        },
        pages: [
          MaterialPage(child: _searchPage()),
          if (routeState.hasMedia())
            MaterialPage(child: PlayerRoute(media: routeState.media!))
        ],
      );

  Widget _searchPage() => Container(
        //TODO: Try to bring this in line with padding of other pages
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [_searchInput(), Expanded(child: _searchResults())],
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

  Row _searchInput() {
    return Row(
      children: [
        Expanded(
            child: FutureBuilder<bool>(
                future: searchService.hasResults,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  return TextField(
                    controller: _controller,
                    focusNode: _searchFocus,
                    autofocus: !routeState.hasMedia() && !snapshot.data!,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        hintText: 'Search'),
                    onChanged: (value) => searchService.setSearch(value),
                    onSubmitted: (value) => searchService.setSearch(value),
                  );
                })),
        StreamBuilder<bool>(
            stream: _hasFocus,
            builder: (context, snapshot) => snapshot.hasData && snapshot.data!
                ? IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => _searchFocus.unfocus())
                : IconButton(
                    onPressed: () => _searchFocus.requestFocus(),
                    icon: Icon(Icons.search)))
      ],
    );
  }
}
