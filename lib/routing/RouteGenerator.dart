import 'package:app/screens/add_procedure_record/add_procedure_record_screen_model.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_model.dart';
import 'package:app/screens/actions_overview/actions_overview_screen.dart';
import 'package:app/screens/archive/archive_screen_model.dart';
import 'package:app/screens/summary/summary_screen_model.dart';
import 'package:app/screens/archive/archive_screen.dart';
import 'package:app/screens/main/main_screen_model.dart';
import 'package:app/screens/summary/summary_screen.dart';
import 'package:app/screens/main/main_screen.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/app_state.dart';


class RouteGenerator {
  AppState _appState;

  RouteGenerator(this._appState);


  Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case MainScreen.routeName: return MaterialPageRoute(
          builder: (_) => Provider<MainScreenModel>(
            create: (context) => MainScreenModel(_appState),
            child: MainScreen(),
            dispose: (context, model) => model.dispose(),
          )
      );

      case AddProcedureRecordScreen.routeName: return MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (context) => AddProcedureRecordScreenModel(args as ProcedureRecord, _appState),
          child: AddProcedureRecordScreen(),
        )
      );

      case SummaryScreen.routeName: return MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (context) => SummaryScreenModel(DateTime.now()),
          child: SummaryScreen(),
        )
      );

      case SummaryScreen.archiveRouteName: return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SummaryScreenModel(args as DateTime),
            child: SummaryScreen(),
          )
      );

      case ActionsOverviewScreen.routeName: return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ActionsOverviewScreeModel(_appState),
            child: ActionsOverviewScreen(),
          )
      );

      case ArchiveScreen.routeName: return MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (context) => ArchiveScreenModel(),
          child: ArchiveScreen(),
        )
      );

      default:
        return _errorRoute();
    }
  }


  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Error'),
        ),
      );
    });
  }
}