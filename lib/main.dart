import 'package:flutter/material.dart';
import 'package:inside_chassidus/data/insideData.dart';
import 'package:inside_chassidus/screens/top-lessons.dart';
import 'screens/site-section/index.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inside Chassidus',
      theme: ThemeData(primarySwatch: Colors.grey),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SiteSectionWidget.routeName:
            final SiteSection routeSection = settings.arguments;
            return MaterialPageRoute(
                builder: (context) => SiteSectionWidget(section: routeSection));
        }

        return null;
      },
      home: TopLessons(),
    );
  }
}
