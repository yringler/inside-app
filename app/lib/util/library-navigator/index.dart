import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/routes/ternary-section-route.dart';
import 'package:inside_chassidus/util/library-navigator/library-position-service.dart';
import 'package:inside_data/inside_data.dart';
export 'package:inside_chassidus/util/library-navigator/library-position-service.dart';

class LibraryNavigator extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final LibraryPositionService appState =
      BlocProvider.getDependency<LibraryPositionService>(); // Get from DI
  final GlobalKey<NavigatorState> navigatorKey;

  LibraryNavigator({required this.navigatorKey}) {
    appState.addListener(notifyListeners);
  }

  @override
  Widget build(BuildContext context) {
    final wasNavigatedTo =
        appState.sections.where((section) => section.wasNavigatedTo).toList();

    final bookPages = [
      for (final book in wasNavigatedTo)
        MaterialPage(
            key: ValueKey('${book.level}_${book.data!.id}'),
            child: Material(child: getChild(book)))
    ];

    final wasNavigatedToIds = wasNavigatedTo
        .where((element) => element.data != null)
        .map((e) => e.data!.id)
        .toSet();

    final pagesHasTopParent = topImagesInside.keys
        .map((k) => k.toString())
        .any((element) => wasNavigatedToIds.contains(element));

    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        return appState.removeLast();
      },
      pages: [
        // Add home to stack if user navigated to a direct child of home,
        // *or* if user hasn't gone anywhere yet (you have to start somewhere).
        // This means that if library is navigated to from a diffirent tab, back button will not bring
        // to library home - it is up to the app to catch the pop and show the right tab.
        if (bookPages.isEmpty || pagesHasTopParent)
          MaterialPage(
              key: ValueKey("PrimarySectionsRoute"),
              child: getPrimary(context)),
        ...bookPages
      ],
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async {}

  Widget getPrimary(BuildContext context) {
    //TODO: Hardcoding all of this for now. Perhaps some of it can be made dynamic down the line.
    final children = [
      getItem(
          context: context,
          title: 'Featured Classes',
          child: AspectRatio(
            aspectRatio: 9 / 3,
            child: Image.network(
              'https://media.insidechassidus.org/wp-content/uploads/20211125105910/chanuka.gif',
            ),
          )),
      getItem(
          context: context,
          title: 'Daily Study',
          //TODO: Size buttons according to mockup
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 7.5),
                      child: ElevatedButton(
                        onPressed: () => null,
                        child: Text('Tanya'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 7.5),
                      child: ElevatedButton(
                        onPressed: () => null,
                        child: Text('Hayom Yom'),
                      ),
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () => null,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      //TODO: We use this icon across the board, is it good? Should we make it smaller? Change it everywhere perhaps?
                      child: Icon(Icons.signal_cellular_alt),
                    ),
                    Text('Most Popular Classes'),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => null,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(Icons.schedule),
                    ),
                    Text('Recently Uploaded Classes'),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ],
          )),
      getItem(
        context: context,
        title: 'Browse Categories',
        child: PrimarySectionsRoute(),
      ),
    ];

    return ListView.separated(
      padding: EdgeInsets.all(15),
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      itemCount: children.length,
    );
  }

  //TODO: Make into widget if using BuildContext?
  Widget getItem(
      {required BuildContext context,
      required String title,
      required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Text(title,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headline6!.fontSize)),
        ),
        child
      ],
    );
  }

  Widget getChild(SitePosition book) {
    // (The only time it won't be section is if it's set to media on back to
    // library button in player route. This is a bit clumsy - really, it shouldn't
    // fire untill it's all set up.)
    if (book.level == 0 && book.data is Section) {
      return SecondarySectionRoute(
        section: book.data as Section,
      );
    }

    switch (book.data.runtimeType) {
      case Section:
        return TernarySectionRoute(
          section: book.data as Section,
        );
      // TODO: implement lesson route? Remove it?
      // case MediaSection:
      //   return LessonRoute(
      //     lesson: book.data as MediaSection,
      //   );
      case Media:
        return PlayerRoute(media: book.data as Media);
    }

    throw new ArgumentError.value(book, 'Could not create widget for value');
  }
}
