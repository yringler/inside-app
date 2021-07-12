import 'package:flutter/material.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';

class LessonTab extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  LessonTab({required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final backButtonDispatcher = Router.of(context)
        .backButtonDispatcher!
        .createChildBackButtonDispatcher();

    backButtonDispatcher.takePriority();

    return Router<void>(
        routerDelegate: LibraryNavigator(navigatorKey: navigatorKey),
        backButtonDispatcher: backButtonDispatcher);
  }
}
