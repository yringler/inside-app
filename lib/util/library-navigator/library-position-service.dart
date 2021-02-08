import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_api/site-service.dart';

/// Supports setting a new active section.
/// Stores a list of parents and current item (keeping note if parents weren't
/// navigated to, e.g. because user navigated from previously played to its section)
/// a thin abstraction around the page stack for the router
class LibraryPositionService extends ChangeNotifier {
  final SiteBoxes siteBoxes;
  List<SitePosition> sections = [];

  LibraryPositionService({@required this.siteBoxes});

  /// Ensure that next to last item is parent of new item, or clear the list.
  /// If new parent isn't in list, replace the list with it and its ancestors.
  /// Make note that they were never navigated to (and so shouldn't show up
  /// e.g. when user hits back button)
  Future<List<SitePosition>> setActiveItem(SiteDataItem item) async {
    if (sections.last.data == item) {
      return sections;
    }

    // Check if new item can be added to current list (if its parent is there).
    final parentIndex =
        sections.indexWhere((section) => section.data.id == item.parentId);

    if (parentIndex != -1) {
      sections = sections.sublist(parentIndex);
      sections.add(SitePosition(data: item, level: sections.length));
    } else {
      _clearTo(item);
    }

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

  /// Clear the saved list, and reset to the given item and all of its parents.
  _clearTo(SiteDataItem item) async {
    sections.clear();
    sections.add(SitePosition(data: item));

    // Add all the parents to the list. These aren't used for some navigation (the
    // back button won't get you there), but they are used for explicit navigation
    // (e.g. clicking a parent section button), and to provide context to a class.
    var lastItemAdded = item;
    while ((lastItemAdded.closestSectionId ?? 0) != 0) {
      final parentSection =
          await this.siteBoxes.sections.get(lastItemAdded.closestSectionId);

      // This is the case for media which is in a MediaSection. The parentId is set
      // to the MediaSection, and the closestSectionId is the section the MediaSection
      // is in.
      if (lastItemAdded.closestSectionId != lastItemAdded.parentId) {
        assert(lastItemAdded is Media);
        final mediaSectionId = lastItemAdded.parentId;
        final parentMediaSection = parentSection.content
            .firstWhere((content) => content.mediaSection?.id == mediaSectionId)
            .mediaSection;
        sections.insert(
            0, SitePosition(data: parentMediaSection, wasNavigatedTo: false));
      }

      sections.insert(0, SitePosition(data: parentSection));
      lastItemAdded = parentSection;
    }

    for (int i = 0; i < sections.length; i++) {
      sections[i].level = i;
    }
  }
}

class SitePosition {
  final SiteDataItem data;
  final bool wasNavigatedTo;
  // For example, the top level section (which would be on the home screen)
  // would be level 0. A child would be level 1, etc.
  int level;

  SitePosition({this.data, this.wasNavigatedTo = true, this.level});
}
