import 'package:app/domain/procedure_immutable.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:collection';


class AppBloc extends Bloc<AppEvent, AppState>{


  AppBloc() : super(AppStateLoadInProgress());


  @override
  Stream<AppState> mapEventToState(AppEvent event) async*{
    if (event is InitializedApp) {
      yield* _initializedAppToState(event);

    } else if (event is AppProcedureAdded) {
      yield* _appProcedureAddedToSTate(event);

    } else if (event is AppProcedureUpdated) {
      yield* _appProcedureUpdatedToSTate(event);
    }
  }


  Stream<AppState> _initializedAppToState(InitializedApp event) async*{
    yield AppStateLoadInProgress();
    var proceduresSearch = await SQLiteDbProvider.db.findAllProcedures();
    if (proceduresSearch.isSuccess) {
      yield AppLoadSuccess(UnmodifiableListView(proceduresSearch.value));

    } else {
      yield AppLoadFail(proceduresSearch.lastMessage);
    }
  }


  Stream<AppState> _appProcedureAddedToSTate(AppProcedureAdded event) async*{
    if (state is AppLoadSuccess) {
      List<ProcedureImmutable> updatedList = List.from((state as AppLoadSuccess).procedures);
      updatedList.insert(0, event.procedure);
      yield AppLoadSuccess(UnmodifiableListView(updatedList));
    }
  }


  Stream<AppState> _appProcedureUpdatedToSTate(AppProcedureUpdated event) async*{
    if (state is AppLoadSuccess) {
      List<ProcedureImmutable> updatedList = List.from((state as AppLoadSuccess).procedures);

      int index = updatedList.indexWhere((element) => element.id == event.procedure.id);
      updatedList.removeAt(index);
      updatedList.insert(index, event.procedure);

      yield AppLoadSuccess(UnmodifiableListView(updatedList));
    }
  }
}


// events

abstract class AppEvent {}


class InitializedApp extends AppEvent {}

class AppProcedureAdded extends AppEvent {
  final ProcedureImmutable procedure;

  AppProcedureAdded(this.procedure);
}


class AppProcedureUpdated extends AppEvent {
  final ProcedureImmutable procedure;

  AppProcedureUpdated(this.procedure);
}


// States

abstract class AppState {}


class AppStateLoadInProgress extends AppState {}


class AppLoadSuccess extends AppState {
  final UnmodifiableListView<ProcedureImmutable> procedures;

  AppLoadSuccess(this.procedures);
}


class AppProcedureCreationSuccess extends AppLoadSuccess {
  AppProcedureCreationSuccess(UnmodifiableListView<ProcedureImmutable> procedures) : super(procedures);
}


class AppProcedureUpdateSuccess extends AppLoadSuccess {
  AppProcedureUpdateSuccess(UnmodifiableListView<ProcedureImmutable> procedures) : super(procedures);
}


class AppLoadFail extends AppState {
  final String errorMessage;

  AppLoadFail(this.errorMessage);
}