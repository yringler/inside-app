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

  LessonTab({this.onRouteChange, @required this.navigatorKey});

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        observers: [BreadcrumbsNavigateUpdater()],
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
              MediaSection dataSection = data;
              // See comment in section-content-list.dart about this. Basically,
              // I set parent ID to section ID over there.
              // Which is it's intended usage... maybe I should rename it.
              builder = (context) => LessonRoute(
                  lesson: dataSection, sectionId: dataSection.parentId);
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
              .isOtherButtonsShowing(isShowing: isMediaButtonsShowing);

          final breadService = BlocProvider.getBloc<BreadcrumbService>();

          final isRoot = settings.name == '/' ||
              settings.name == PrimarySectionsRoute.routeName;

          if (isRoot) {
            breadService.clear();
          } else {
            breadService.setCurrentBread(
                routeName: settings.name,
                argument: settings.arguments,
                label: data.title);
          }

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

/// Ensures that, if user uses back button to go to parent section, further bread
/// crumbs are built from the parent point, not appended to previous child section.
class BreadcrumbsNavigateUpdater extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    // If this method modifies the data, navigating to main and going to diffirent
    // section causes error:
    // 'package:flutter/src/widgets/navigator.dart': Failed assertion: line 4080 pos 12: '!_debugLocked': is not true.
    // return;

    final service = BlocProvider.getBloc<BreadcrumbService>();

    if (route.settings.arguments != null) {
      // We don't know wether previous or current route are parent or child.
      // So remove untill whichever is higher, and than add bread for current screen.
      service.removeUntil(
          route: route.settings.name, argument: route.settings.arguments);
      service.removeUntil(
          route: previousRoute.settings.name,
          argument: previousRoute.settings.arguments);

      service.setCurrentBread(
          routeName: previousRoute.settings.name,
          argument: previousRoute.settings.arguments,
          label: (previousRoute.settings.arguments as SiteDataItem).title);
    } else if (route.settings.name == '/' ||
        route.settings.name == PrimarySectionsRoute.routeName) {
      service.clear();
    }
  }
}
