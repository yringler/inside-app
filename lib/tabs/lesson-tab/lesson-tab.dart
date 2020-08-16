import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/blocs/is-player-buttons-showing.dart';
import 'package:inside_chassidus/routes/lesson-route/index.dart';
import 'package:inside_chassidus/routes/player-route/player-route.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/routes/ternary-section-route.dart';

typedef RouteChangedCallback = void Function(RouteSettings);

class LessonTab extends StatelessWidget {
  final RouteChangedCallback onRouteChange;

  final GlobalKey<NavigatorState> navigatorKey;

  LessonTab({this.onRouteChange, @required this.navigatorKey});

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) {
          WidgetBuilder builder;
          SiteDataItem data;

          bool isMediaButtonsShowing = false;

          switch (settings.name) {
            case '/':
            case PrimarySectionsRoute.routeName:
              builder = (context) => PrimarySectionsRoute();
              break;
            case SecondarySectionRoute.routeName:
              data = settings.arguments;
              builder = (context) => SecondarySectionRoute(section: data);
              break;
            case LessonRoute.routeName:
              data = settings.arguments;
              builder = (context) => LessonRoute(lesson: data);
              break;
            case TernarySectionRoute.routeName:
              data = settings.arguments;
              builder = (context) => TernarySectionRoute(section: data);
              break;
            case PlayerRoute.routeName:
              isMediaButtonsShowing = true;
              data = settings.arguments;
              builder = (context) => PlayerRoute(media: data);
              break;
            default:
              throw ArgumentError("Unknown route: ${settings.name}");
          }

          BlocProvider.getBloc<IsPlayerButtonsShowingBloc>()
              .isPlayerButtonsShowing(isShowing: isMediaButtonsShowing);

          onRouteChange(settings);

          return MaterialPageRoute(builder: builder);
        },
        initialRoute: PrimarySectionsRoute.routeName,
      );
}
