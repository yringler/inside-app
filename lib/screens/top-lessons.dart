import 'package:flutter/material.dart';

class TopLessons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _title(context),
      ),
      body: Row(
        children: [_search(), _sections()],
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text("Inside Chassidus",
          style: Theme.of(context).appBarTheme.textTheme.title),
    );
  }

  Widget _search() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search",
            suffixIcon: Icon(Icons.search)
            ),
        ));
  }
}
