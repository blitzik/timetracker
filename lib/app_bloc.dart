import 'package:app/domain/procedure_immutable.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:collection';


class AppBloc extends Bloc<AppEvent, AppState>{

  @override
  AppState get initialState => AppStateLoadInProgress();


  @override
  Stream<AppState> mapEventToState(AppEvent event) async*{
    if (event is InitializedApp) {
      yield* _initializedAppToStat(event);
    }
  }


  Stream<AppState> _initializedAppToStat(InitializedApp event) async*{
    yield AppStateLoadInProgress();
    var proceduresSearch = await SQLiteDbProvider.db.findAllProcedures();
    if (proceduresSearch.isSuccess) {
      yield AppLoadSuccessful(UnmodifiableListView(proceduresSearch.result));

    } else {
      yield AppLoadFail(proceduresSearch.lastMessage);
    }
  }
}


// events

abstract class AppEvent {}


class InitializedApp extends AppEvent {}



// States

abstract class AppState {}


class AppStateLoadInProgress extends AppState {}


class AppLoadSuccessful extends AppState {
  final UnmodifiableListView<ProcedureImmutable> procedures;

  AppLoadSuccessful(this.procedures);
}


class AppLoadFail extends AppState {
  final String errorMessage;

  AppLoadFail(this.errorMessage);
}