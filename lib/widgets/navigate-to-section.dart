import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/routes/secondary-section-route/index.dart';
import 'package:inside_chassidus/widgets/inside-navigator.dart';

/// Navigates to given section when child is tapped.
class NavigateToSection extends InsideNavigator {
  NavigateToSection({@required Widget child, @required Section section})
  : super(child: child, data: section, routeName: SecondarySectionRoute.routeName);
}
