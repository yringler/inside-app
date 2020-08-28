import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb_menu/flutter_breadcrumb_menu.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/blocs/is-player-buttons-showing.dart';
import 'package:inside_chassidus/routes/lesson-route/index.dart';
import 'package:inside_chassidus/routes/player-route/player-route.dart';
import 'package:inside_chassidus/routes/primary-section-route.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/routes/ternary-section-route.dart';
import 'package:inside_chassidus/util/bread-crumb-service.dart';

typedef RouteChangedCallback = void Function(RouteSettings);

class LessonTab extends StatelessWidget {
  final RouteChangedCallback onRouteChange;

  final GlobalKey<NavigatorState> navigatorKey;

  final BreadcrumbService breadService;

  LessonTab(
      {this.onRouteChange,
      @required this.navigatorKey,
      @required this.breadService});

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) {
          WidgetBuilder builder;
          SiteDataItem data = settings.arguments;

          bool isMediaButtonsShowing = false;

          final isRoot = settings.name == '/' ||
              settings.name == PrimarySectionsRoute.routeName;

          if (isRoot) {
            breadService.clear();
          } else {
            breadService.setCurrentBread(
                routeName: settings.name, siteData: data);
          }

          final breads = List<Bread>.from(breadService.breads);

          switch (settings.name) {
            case '/':
            case PrimarySectionsRoute.routeName:
              builder = (context) => PrimarySectionsRoute();
              break;
            case SecondarySectionRoute.routeName:
              builder = (context) =>
                  SecondarySectionRoute(section: data, breads: breads);
              break;
            case LessonRoute.routeName:
              builder =
                  (context) => LessonRoute(lesson: data, breads: breads);
              break;
            case TernarySectionRoute.routeName:
              builder = (context) => TernarySectionRoute(
                    section: data,
                    breads: breads,
                  );
              break;
            case PlayerRoute.routeName:
              isMediaButtonsShowing = true;
              builder = (context) => PlayerRoute(media: data);
              break;
            default:
              throw ArgumentError("Unknown route: ${settings.name}");
          }

          BlocProvider.getBloc<IsPlayerButtonsShowingBloc>()
              .isOtherButtonsShowing(isShowing: isMediaButtonsShowing);

          onRouteChange(settings);

          return MaterialPageRoute(
              builder: (context) => Material(
                    child: builder(context),
                  ),
              settings: settings);
        },
        initialRoute: PrimarySectionsRoute.routeName,
      );
}
