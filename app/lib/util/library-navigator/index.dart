import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_chassidus/routes/player-route/index.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/routes/ternary-section-route.dart';
import 'package:inside_chassidus/util/library-navigator/library-position-service.dart';
import 'package:inside_data_flutter/inside_data_flutter.dart';
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
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          return appState.removeLast();
        },
        pages: [
          MaterialPage(
              key: ValueKey("PrimarySectionsRoute"),
              child: PrimarySectionsRoute()),
          for (final book
              in appState.sections.where((section) => section.wasNavigatedTo))
            MaterialPage(
                key: ValueKey('${book.level}_${book.data!.id}'),
                child: Material(child: getChild(book)))
        ],
      );

  @override
  Future<void> setNewRoutePath(configuration) async {}

  Widget getChild(SitePosition book) {
    // (The only time it won't be section is if it's set to media on back to
    // library button in player route. This is a bit clumsy - really, it shouldn't
    // fire untill it's all set up.)
    if (book.level == 0 && book.data is Section) {
      return SecondarySectionRoute(
        section: book.data as Section?,
      );
    }

    switch (book.data.runtimeType) {
      case Section:
        return TernarySectionRoute(
          section: book.data as Section?,
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
