import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/routes/secondary-section-route/widgets/inside-data-card.dart';
import 'package:inside_chassidus/tabs/widgets/simple-media-list-widgets.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';
import 'package:inside_chassidus/widgets/media-list/media-item.dart';
import 'package:inside_chassidus/widgets/section-content-list.dart';
import 'package:inside_data/inside_data.dart';
import 'package:rxdart/subjects.dart';

class SearchResultsTab extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final MediaListTabRoute routeState;

  const SearchResultsTab(
      {Key? key, required this.navigatorKey, required this.routeState});

  @override
  State<StatefulWidget> createState() => SearchResultsTabState();
}

class SearchResultsTabState extends State<SearchResultsTab> {
  @override
  Widget build(BuildContext context) => Router(
      backButtonDispatcher: Router.of(context)
          .backButtonDispatcher!
          .createChildBackButtonDispatcher()
        ..takePriority(),
      routerDelegate: SearchTabTabNavigator(
          key: widget.navigatorKey, state: widget.routeState));
}

class SearchForm extends StatefulWidget {
  final MediaListTabRoute routeState;
  final WordpressSearch searchService =
      BlocProvider.getDependency<WordpressSearch>();

  SearchForm({required this.routeState});

  @override
  State<StatefulWidget> createState() => SearchFormState();
}

class SearchFormState extends State<SearchForm> {
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
  Widget build(BuildContext context) => Container(
        //TODO: Try to bring this in line with padding of other pages
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [_searchInput(), _searchResults()],
        ),
      );

  Widget _searchResults() {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) => _searchFocus.unfocus(),
        onTap: () => _searchFocus.unfocus(),
        child: StreamBuilder<List<ContentReference>>(
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
                      : SearchFormResults(
                          content: snapshot.data!,
                          routeDataService: widget.routeState)));
            }),
      ),
    );
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
                    autofocus: !widget.routeState.hasMedia() && !snapshot.data!,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        hintText: 'Search',
                        suffixIcon: IconButton(
                          onPressed: () => searchService.setSearch(''),
                          icon: Icon(Icons.clear),
                        )),
                    onChanged: (value) => searchService.setSearch(value),
                    onSubmitted: (value) => searchService.setSearch(value),
                  );
                }))
      ],
    );
  }
}

class SearchFormResults extends StatelessWidget {
  final List<ContentReference> content;
  final IRoutDataService routeDataService;

  const SearchFormResults(
      {required this.content, required this.routeDataService});

  @override
  Widget build(BuildContext context) => SectionContentList(
        content: content,
        sectionBuilder: (context, section) => InsideNavigator(
            data: section, child: InsideDataCard(insideData: section)),
        lessonBuilder: (context, lesson) => InsideDataCard(insideData: lesson),
        mediaBuilder: (context, media) => MediaItem(
          media: media,
          sectionId: null,
          routeDataService: routeDataService,
        ),
      );
}

class SearchTabTabNavigator extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> key;
  final MediaListTabRoute state;

  SearchTabTabNavigator({required this.key, required this.state}) {
    this.state.addListener(notifyListeners);
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

          return state.clear();
        },
        pages: [
          MaterialPage(child: SearchForm(routeState: state)),
          if (state.hasMedia())
            MaterialPage(child: PlayerRoute(media: state.media!))
        ],
      );

  @override
  // TODO: implement navigatorKey
  GlobalKey<NavigatorState>? get navigatorKey => key;

  @override
  Future<void> setNewRoutePath(configuration) async {}
}
