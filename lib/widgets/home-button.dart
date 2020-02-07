import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialButton(
      child: Icon(Icons.home),
      onPressed: () =>
          Navigator.of(context).pushNamedAndRemoveUntil("/", (_) => false));
}
