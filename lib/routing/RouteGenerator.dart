import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen_bloc.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_bloc.dart';
import 'package:app/screens/actions_overview/actions_overview_screen.dart';
import 'package:app/screens/archive/archive_screen_bloc.dart';
import 'package:app/screens/summary/summary_screen_bloc.dart';
import 'package:app/screens/archive/archive_screen.dart';
import 'package:app/screens/summary/summary_screen.dart';
import 'package:app/screens/main/main_screen_bloc.dart';
import 'package:app/screens/main/main_screen.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';


class RouteGenerator {

  RouteGenerator();


  Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case MainScreen.routeName: return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => MainScreenBloc(),
            child: MainScreen(),
          )
      );

      case AddProcedureRecordScreen.routeName: return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => AddProcedureRecordScreenBloc(args as ProcedureRecordImmutable),
          child: AddProcedureRecordScreen(),
        )
      );

      case SummaryScreen.routeName: return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => SummaryScreenBloc(args as DateTime),
          child: SummaryScreen()
        )
      );

      case ActionsOverviewScreen.routeName: return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ActionsOverviewScreenBloc(),
            child: ActionsOverviewScreen(),
          )
      );

      case ArchiveScreen.routeName: return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => ArchiveScreenBloc(),
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