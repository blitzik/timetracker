import 'package:app/screens/add_procedure_record/add_procedure_record_screen_bloc.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_bloc.dart';
import 'package:app/screens/actions_overview/actions_overview_screen.dart';
import 'package:app/screens/editable_overview/editable_overview_bloc.dart';
import 'package:app/screens/editable_overview/editable_overview.dart';
import 'package:app/screens/archive/archive_screen_bloc.dart';
import 'package:app/screens/summary/summary_screen_bloc.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/screens/archive/archive_screen.dart';
import 'package:app/screens/summary/summary_screen.dart';
import 'package:app/screens/main/main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:app/app_bloc.dart';


class RouteGenerator {

  final AppBloc _appBloc;

  RouteGenerator(this._appBloc);


  Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/': return MaterialPageRoute(
        builder: (context) => MainScreen()
      );

      case EditableOverview.routeName: return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => EditableOverviewBloc(args as DateTime),
          child: EditableOverview(),
        )
      );

      case AddProcedureRecordScreen.routeName: return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => AddProcedureRecordScreenBloc(args as ProcedureRecordImmutable, (_appBloc.state as AppLoadSuccess).procedures),
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
          create: (context) => ActionsOverviewScreenBloc(_appBloc),
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