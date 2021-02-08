import 'package:flutter/material.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';

class LessonTab extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  final bool isActive;

  LessonTab(
      {@required this.navigatorKey,
      @required this.isActive});

  @override
  Widget build(BuildContext context) {
    final backButtonDispatcher = Router.of(context)
        .backButtonDispatcher
        .createChildBackButtonDispatcher();

    if (isActive) {
      backButtonDispatcher.takePriority();
    }

    return Router(
        routerDelegate: LibraryNavigator(navigatorKey: navigatorKey),
        backButtonDispatcher: backButtonDispatcher);
  }
}
