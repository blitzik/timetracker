import 'package:intl/date_symbol_data_local.dart';
import 'package:app/routing/RouteGenerator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/app_state.dart';
import 'package:intl/intl.dart';


void main() {
  Intl.defaultLocale = 'cs_CS';
  initializeDateFormatting();

  AppState appState = AppState(DateTime.now());
  RouteGenerator routeGenerator = RouteGenerator(appState);

  runApp(App(appState, routeGenerator));
}


class App extends StatelessWidget{

  final AppState _appState;
  final RouteGenerator _routeGenerator;


  App(this._appState, this._routeGenerator);


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value:  _appState,
      child: MaterialApp(
        title: 'TimeTracker',
        theme: ThemeData(
          primaryColor: const Color(0xff34495e),
          inputDecorationTheme: InputDecorationTheme(
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            labelStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: _routeGenerator.generateRoute,
      ),
    );
  }

}