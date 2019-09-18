import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/screens/site-section/site-section-widget.dart';

/// Navigates to given section when child is tapped.
class NavigateToSection extends StatelessWidget {
  final SiteSection section;
  final Widget child;

  NavigateToSection({@required this.child, @required this.section});

  @override
  Widget build(BuildContext context) =>
      GestureDetector(onTap: () => _navigateToSection(context), child: child);

  _navigateToSection(BuildContext context) {
    Navigator.pushNamed(context, SiteSectionWidget.routeName,
        arguments: section);
  }
}
