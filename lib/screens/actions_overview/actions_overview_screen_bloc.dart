import 'package:app/screens/actions_overview/actions_overview_screen_events.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_states.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:collection';


class ActionsOverviewScreenBloc extends Bloc<ActionsOverviewScreenEvent, ActionsOverviewScreenState> {

  @override
  ActionsOverviewScreenState get initialState => ActionsOverviewLoadInProgress();


  ActionsOverviewScreenBloc();


  @override
  Stream<ActionsOverviewScreenState> mapEventToState(ActionsOverviewScreenEvent event) async*{
    if (event is ActionsOverviewLoaded) {
      yield* _actionsOverviewLoadedToState(event);
    }
  }


  Stream<ActionsOverviewScreenState> _actionsOverviewLoadedToState(ActionsOverviewLoaded event) async*{
    var result = await SQLiteDbProvider.db.findAllProcedures();
    if (!result.isSuccess) {
      yield ActionsOverviewLoadFailure(result.lastMessage);
    } else {
      yield ActionsOverviewLoadSuccess(UnmodifiableListView(result.result));
    }
  }


  void dispose() {
    this.close();
  }
}