import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_breadcrumb_menu/flutter_breadcrumb_menu.dart';
import 'package:inside_api/models.dart';

/// Keep track of what the current bread crumb state is.
class BreadcrumbService extends BlocBase {
  List<Bread> breads = [];

  void setCurrentBread({SiteDataItem siteData, String routeName}) {
    // Sanatize the label and make sure it isn't too big.

    final label = siteData.title.trim().split(' ').take(5).join(' ');

    ensureLastHasId(siteData.parentId);

    // Setting a bread which is already in use rewinds us back to that point.
    if (!removeUntil(route: routeName, argument: siteData)) {
      // Add it if it wasn't there already.
      breads.add(Bread(label: label, route: routeName, arguments: siteData));
    }
  }

  /// Removes breads until bread with matching route and argument is found, exclusive.
  /// Returns true if item was found.
  bool removeUntil({String route, SiteDataItem argument}) {
    if (breads.isEmpty) {
      return false;
    }

    final i = breads.indexWhere(
        (element) => element.arguments == argument && element.route == route);

    if (i > -1) {
      // Eg if exists at first element (index 0), the new length is 1 (index + 1).
      breads.length = i + 1;
    }

    // Return true if item was found.
    return i > -1;
  }

  void clear() {
    breads.clear();
  }

  /// Make sure that the last bread has this ID. Done to make sure that
  /// the parent bread of newly added is always the real parent.
  /// Prevents issues when navigation is from hardware back button.
  void ensureLastHasId(int id) {
    if (id != 0 && id != null) {
      while (breads.isNotEmpty && breads.last.arguments.id != id) {
        breads.removeLast();
      }
    }
  }
}
