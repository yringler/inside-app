import 'package:flutter/material.dart';

class InsidePage extends StatelessWidget {
  final Widget body;

  InsidePage({this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Inside Chasidus'),
        ),
        body: body);
  }
}
