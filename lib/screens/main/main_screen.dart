import 'package:app/screens/actions_overview/actions_overview_screen.dart';
import 'package:app/screens/archive/archive_screen.dart';
import 'package:app/screens/editable_overview/editable_overview.dart';
import 'package:flutter/material.dart';


class MainScreen extends StatelessWidget {
  static const String routeName = '/';

  final TextStyle btnTextStyle = TextStyle(fontSize: 20, color: Colors.white);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TimeTracker'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Color(0xff2980b9),
              child: FlatButton(
                child: Text('Přehled akcí', style: btnTextStyle),
                onPressed: () {
                  Navigator.pushNamed(context, ActionsOverviewScreen.routeName);
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xff34495e),
              child: FlatButton(
                child: Text('Historické záznamy', style: btnTextStyle),
                onPressed: () {
                  Navigator.pushNamed(context, ArchiveScreen.routeName);
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xff27ae60),
              child: FlatButton(
                child: Text('Spravovat dnešní záznamy', style: btnTextStyle),
                onPressed: () {
                  Navigator.pushNamed(context, EditableOverview.routeName, arguments: DateTime.now());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
