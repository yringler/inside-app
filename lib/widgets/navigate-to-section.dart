import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';

/// Navigates to given section when child is tapped.
class NavigateToSection extends InsideNavigator {
  NavigateToSection({@required Widget child, @required SiteSection section})
  : super(child: child, data: section, routeName: SecondarySectionRoute.routeName);
}
