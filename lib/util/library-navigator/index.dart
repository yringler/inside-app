import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/routes/lesson-route/index.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/routes/ternary-section-route.dart';
import 'package:inside_chassidus/util/library-navigator/library-position-service.dart';
export 'package:inside_chassidus/util/library-navigator/library-position-service.dart';

class LibraryNavigator extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final LibraryPositionService appState =
      BlocProvider.getDependency<LibraryPositionService>(); // Get from DI
  final GlobalKey<NavigatorState> navigatorKey;

  LibraryNavigator({@required this.navigatorKey}) {
    appState.addListener(notifyListeners);
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          return appState.removeLast();
        },
        pages: [
          for (final book
              in appState.sections.where((section) => section.wasNavigatedTo))
            MaterialPage(
                key: ValueKey('${book.level}_${book.data.id}'),
                child: getChild(book))
        ],
      );

  @override
  Future<void> setNewRoutePath(configuration) async {}

  Widget getChild(SitePosition book) {
    if (book.data is Media) {
      return PlayerRoute(media: book.data);
    }

    switch (book.level) {
      case 0:
        return PrimarySectionsRoute();
      case 1:
        return SecondarySectionRoute(
          section: book.data,
        );
    }

    switch (book.data.runtimeType) {
      case Section:
        return TernarySectionRoute(
          section: book.data,
        );
      case MediaSection:
        return LessonRoute(
          lesson: book.data,
        );
    }

    throw new ArgumentError.value(book, 'Could not create widget for value');
  }
}
