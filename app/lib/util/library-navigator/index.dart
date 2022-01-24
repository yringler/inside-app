import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/routes/secondary-section-route/widgets/inside-data-card.dart';
import 'package:inside_chassidus/routes/ternary-section-route.dart';
import 'package:inside_chassidus/util/library-navigator/library-position-service.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';
import 'package:inside_chassidus/widgets/media-with-context.dart';
import 'package:inside_chassidus/widgets/section-content-list.dart';
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
            key: ValueKey(book.data!.id),
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
        if (bookPages.isEmpty ||
            pagesHasTopParent ||
            appState.backToTop ||
            appState.sectionCollection.virtualSection.isNotEmpty)
          MaterialPage(
              key: ValueKey("PrimarySectionsRoute"),
              child: PrimarySectionsRoute()),
        if (appState.sectionCollection.virtualSection.isNotEmpty)
          _virtualSection(),
        ...bookPages
      ],
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async {}

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

  // A bunch of content whose relationship is other than from data. For example, popular classes.
  MaterialPage _virtualSection() {
    return MaterialPage(
        child: Material(
      child: SectionContentList(
        content: appState.sectionCollection.virtualSection,
        sectionBuilder: (context, section) => InsideNavigator(
            data: section, child: InsideDataCard(insideData: section)),
        lessonBuilder: (context, lesson) => InsideDataCard(insideData: lesson),
        mediaBuilder: (context, media) => MediaWithContext(
            media: media, onTap: () => appState.setActiveItem(media)),
      ),
    ));
  }
}
