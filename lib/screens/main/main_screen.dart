import 'package:app/screens/actions_overview/actions_overview_screen.dart';
import 'package:app/screens/editable_overview/editable_overview.dart';
import 'package:app/screens/archive/archive_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:app/app_bloc.dart';


class MainScreen extends StatelessWidget {
  static const String routeName = '/';

  final TextStyle btnTextStyle = TextStyle(fontSize: 20, color: Colors.white);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TimeTracker'),
      ),
      body: BlocBuilder<AppBloc, AppState>(
        condition: (oldState, newState) {
          if (newState is AppProcedureCreationSuccess ||
              newState is AppProcedureUpdateSuccess) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          if (state is AppStateLoadInProgress) {
            return Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text('Načítám data...', style: TextStyle(fontSize: 25)),
                  ),
                  SizedBox(height: 50),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator()
                  ),
                ],
              ),
            );
          }

          if (state is AppLoadFail) {
            return Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text('Při startu aplikace došlo k chybě', style: TextStyle(fontSize: 22)),
                    subtitle: Text(state.errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                  SizedBox(height: 50),
                  Icon(Icons.error, size: 200, color: Colors.red,)
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Color(0xff2980b9),
                  child: FlatButton(
                    child: ListTile(
                      leading: Icon(Icons.view_headline, size: 50, color: Colors.white),
                      title: Text('Přehled akcí', style: btnTextStyle)
                    ),
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
                    child: ListTile(
                      leading: Icon(Icons.archive, size: 50, color: Colors.white),
                      title: Text('Historické záznamy', style: btnTextStyle)
                    ),
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
                    child: ListTile(
                      leading: Icon(Icons.access_time, size: 50, color: Colors.white),
                      title: Text('Spravovat dnešní záznamy', style: btnTextStyle)
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, EditableOverview.routeName, arguments: DateTime.now());
                    },
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
