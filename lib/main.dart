import 'package:app/screens/editable_overview/editable_overview.dart';
import 'package:app/screens/main/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app/routing/RouteGenerator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:app/app_bloc.dart';
import 'package:intl/intl.dart';


void main() {
  Intl.defaultLocale = 'cs_CS';
  initializeDateFormatting();


  RouteGenerator routeGenerator = RouteGenerator();

  runApp(App(routeGenerator));
}


class App extends StatelessWidget{
  final RouteGenerator _routeGenerator;


  App(this._routeGenerator);


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppBloc(),
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
        initialRoute: MainScreen.routeName,
        onGenerateRoute: _routeGenerator.generateRoute,
      ),
    );
  }

}