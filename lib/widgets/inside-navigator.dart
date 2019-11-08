import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/models/inside-data/index.dart';

/// Simplify navigation to a route which depends on inside chassidus data.
class InsideNavigator extends StatelessWidget {
  final String routeName;
  final Widget child;
  final InsideDataBase data;

  InsideNavigator(
      {@required this.routeName, @required this.child, @required this.data});

  @override
  Widget build(BuildContext context) =>
      GestureDetector(onTap: () => _navigate(context), child: child);

  _navigate(BuildContext context) =>
      Navigator.pushNamed(context, routeName, arguments: data);
}
