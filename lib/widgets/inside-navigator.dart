import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';

/// Simplify navigation to a route which depends on inside chassidus data.
class InsideNavigator extends StatelessWidget {
  final String routeName;
  final Widget child;
  final SiteDataItem data;

  InsideNavigator(
      {@required this.routeName, @required this.child, @required this.data});

  @override
  Widget build(BuildContext context) =>
      GestureDetector(onTap: () => _navigate(context), child: child);

  _navigate(BuildContext context) =>
      Navigator.of(context).pushNamed(routeName, arguments: data);
}
