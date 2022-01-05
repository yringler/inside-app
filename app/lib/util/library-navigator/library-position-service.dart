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
  List<SitePosition> get sections => sectionCollection.positions;
  bool get backToTop => sectionCollection.forceCanPopToHome;
  SitePositionCollection sectionCollection =
      SitePositionCollection(positions: []);

  LibraryPositionService({required this.siteBoxes});

  /// Ensure that next to last item is parent of new item, or clear the list.
  /// If new parent isn't in list, replace the list with it and its ancestors.
  /// Make note that they were never navigated to (and so shouldn't show up
  /// e.g. when user hits back button)
  /// If [backToTop] is true, force enable navigate to home page.
  Future<List<SitePosition>> setActiveItem(SiteDataBase? item,
      {bool backToTop = false}) async {
    if (sections.isNotEmpty && sections.last.data == item) {
      notifyListeners();
      return sections;
    }

    await _clearTo(item!, backToTop: backToTop);

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
  Future<void> _clearTo(SiteDataBase item, {bool backToTop = false}) async {
    if (item is Section && item.content.isEmpty) {
      // A query of a section does not return child content IDs, so in router get
      // that info.
      // TODO: I don't think the query will ever return null? Maybe a better
      // behaviour if does.
      item = (await siteBoxes.section(item.id))!;
    }

    final wasNavigatedTo = sections
        .where((element) => element.wasNavigatedTo)
        .map((e) => e.data?.id)
        .where((element) => element != null)
        .cast<String>()
        .toSet();

    final newSections = [
      SitePosition(data: item, level: 0, wasNavigatedTo: true)
    ];

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

      newSections.insert(
          0,
          SitePosition(
              data: parentSection,
              level: newSections.length,
              wasNavigatedTo: wasNavigatedTo.contains(parentSection.id)));
      lastItemAdded = parentSection;
    }

    for (int i = 0; i < newSections.length; i++) {
      newSections[i].level = i;

      // TODO: implement optimize data here?
      // if (sections[i].data is Section) {
      //   await siteBoxes.resolve(sections[i].data as Section);
      // }
    }

    // If this navigation was a click on a list of section content.
    final lastHadParent = sections.any((element) =>
        element.data != null && item.hasParentId(element.data!.id));

    // User can back up to home page if that was forced from argument.
    // Or, user is navigating between children of a section which had that forced.

    sectionCollection = SitePositionCollection(
        positions: newSections,
        forceCanPopToHome:
            (lastHadParent && sectionCollection.forceCanPopToHome) ||
                backToTop);
  }
}

class SitePositionCollection {
  final bool forceCanPopToHome;
  final List<SitePosition> positions;

  SitePositionCollection(
      {this.forceCanPopToHome = false, required this.positions});

  SitePositionCollection copyWith(
          {bool? forceCanPopToHome, List<SitePosition>? positions}) =>
      SitePositionCollection(
          positions: positions ?? this.positions,
          forceCanPopToHome: forceCanPopToHome ?? this.forceCanPopToHome);
}

class SitePosition {
  final SiteDataBase? data;
  final bool wasNavigatedTo;
  // For example, the top level section (which would be on the home screen)
  // would be level 0. A child would be level 1, etc.
  int level;

  SitePosition({this.data, this.wasNavigatedTo = true, required this.level});
}
