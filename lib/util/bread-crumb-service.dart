import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_breadcrumb_menu/flutter_breadcrumb_menu.dart';
import 'package:rxdart/rxdart.dart';

int _indexOfOccurance(final String string,
    {final Pattern pattern, final int occurance}) {
  assert(occurance != null &&
      occurance > 0 &&
      string != null &&
      string.isNotEmpty);

  int index = -1;

  for (var i = 0; i < occurance; i++) {
    index = string.indexOf(pattern, index + 1);
  }

  return index;
}

/// Keep track of what the current bread crumb state is.
class BreadcrumbService extends BlocBase {
  List<Bread> breads = [];
  BehaviorSubject<List<Bread>> _breadsStream = BehaviorSubject.seeded([]);

  Stream<List<Bread>> get breadStream => _breadsStream.stream;

  void setCurrentBread({String label, String routeName, dynamic argument}) {
    // Sanatize the label and make sure it isn't too big.

    label = label.trim().split(' ').take(3).join(' ');

    // final indexOf3rdSpace =
    //     _indexOfOccurance(label, pattern: ' ', occurance: 3);

    // if (indexOf3rdSpace > -1) {
    //   label = label.substring(0, indexOf3rdSpace);
    // }

    // Setting a bread which is already in use rewinds us back to that point.
    if (breads.isNotEmpty) {
      final i = breads.indexWhere((element) =>
          element.label == label &&
          element.arguments == argument &&
          element.route == routeName);

      if (i > -1) {
        breads.length = i;
      }
    }

    breads.add(Bread(label: label, route: routeName, arguments: argument));
    _breadsStream.add(breads);
  }

  void clear() {
    breads.clear();
    _breadsStream.add([]);
  }

  @override
  void dispose() {
    _breadsStream.close();
    super.dispose();
  }
}
