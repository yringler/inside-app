import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:inside_api/models.dart';
import 'package:inside_chassidus/util/library-navigator/index.dart';

/// Simplify navigation to a route which depends on inside chassidus data.
class InsideNavigator extends StatelessWidget {
  final Widget child;
  final SiteDataItem data;

  InsideNavigator({@required this.child, @required this.data});

  @override
  Widget build(BuildContext context) =>
      GestureDetector(onTap: () => _navigate(context), child: child);

  _navigate(BuildContext context) =>
      BlocProvider.getDependency<IRoutDataService>().setActiveItem(data);
}
