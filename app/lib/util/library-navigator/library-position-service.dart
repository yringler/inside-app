import 'package:flutter/material.dart';
import 'package:inside_data/inside_data.dart';

/// A class which hold route data, and allows it to be set.
/// This is useful when a widget can be a part of a couple diffirent routes, and
/// needs a generic way to set the route data for the route it's a part of currently.
///
/// For example, the media player classes.
abstract class IRoutDataService {
  void setActiveItem(SiteDataBase? data);
}

/// Supports setting a new active section.
/// Stores a list of parents and current item (keeping note if parents weren't
/// navigated to, e.g. because user navigated from previously played to its section)
/// a thin abstraction around the page stack for the router
class LibraryPositionService extends ChangeNotifier
    implements IRoutDataService {
  final SiteDataLayer siteBoxes;
  List<SitePosition> sections = [];

  LibraryPositionService({required this.siteBoxes});

  /// Ensure that next to last item is parent of new item, or clear the list.
  /// If new parent isn't in list, replace the list with it and its ancestors.
  /// Make note that they were never navigated to (and so shouldn't show up
  /// e.g. when user hits back button)
  Future<List<SitePosition>> setActiveItem(SiteDataBase? item) async {
    if (sections.isNotEmpty && sections.last.data == item) {
      notifyListeners();
      return sections;
    }

    await _clearTo(item!);

    notifyListeners();
    return sections;
  }

  bool removeLast() {
    if (sections.isNotEmpty) {
      sections.removeLast();
      notifyListeners();
      return true;
    }

    return false;
  }

  clear() {
    if (sections.isNotEmpty) {
      sections.clear();
      notifyListeners();
    }
  }

  /// Clear the saved list, and reset to the given item and all of its parents.
  Future<void> _clearTo(SiteDataBase item) async {
    if (item is Section && item.content.isEmpty) {
      // A query of a section does not return child content IDs, so in router get
      // that info.
      // TODO: I don't think the query will ever return null? Maybe a better
      // behaviour if does.
      item = (await siteBoxes.section(item.id))!;
    }

    sections.clear();
    sections.add(SitePosition(data: item, level: 0));

    // Add all the parents to the list. These aren't used for some navigation (the
    // back button won't get you there), but they are used for explicit navigation
    // (e.g. clicking a parent section button), and to provide context to a class.
    var lastItemAdded = item;
    while (lastItemAdded.hasParent) {
      final parentSection =
          await (this.siteBoxes.section(lastItemAdded.firstParent!));

      if (parentSection == null) {
        print('parent is null');
        break;
      }

      // (Removed code dealing with old Lesson type)

      sections.insert(
          0, SitePosition(data: parentSection, level: sections.length));
      lastItemAdded = parentSection;
    }

    for (int i = 0; i < sections.length; i++) {
      sections[i].level = i;

      // TODO: implement optimize data here?
      // if (sections[i].data is Section) {
      //   await siteBoxes.resolve(sections[i].data as Section);
      // }
    }
  }
}

class SitePosition {
  final SiteDataBase? data;
  final bool wasNavigatedTo;
  // For example, the top level section (which would be on the home screen)
  // would be level 0. A child would be level 1, etc.
  int level;

  SitePosition({this.data, this.wasNavigatedTo = true, required this.level});
}
