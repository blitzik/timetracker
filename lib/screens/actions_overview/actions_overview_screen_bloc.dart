import 'package:app/screens/actions_overview/actions_overview_screen_events.dart';
import 'package:app/screens/actions_overview/actions_overview_screen_states.dart';
import 'package:app/widgets/procedure_form/procedure_form_states.dart';
import 'package:app/widgets/procedure_form/procedure_form_bloc.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/app_bloc.dart';
import 'dart:collection';
import 'dart:async';


class ActionsOverviewScreenBloc extends Bloc<ActionsOverviewScreenEvent, ActionsOverviewScreenState> {
  final AppBloc _appBloc;

  ProcedureFormBloc _formBloc;
  StreamSubscription<ProcedureFormState> _creationFormSubscription;
  ProcedureFormBloc get creationFormBloc {
    if (_formBloc != null) {
      _formBloc.close();
    }
    _formBloc = ProcedureFormBloc(null);
    _creationFormSubscription = _formBloc.listen((onDataState) {
      if (onDataState is ProcedureFormProcessingSuccess) {
      this.add(ActionsOverviewProcedureAdded(onDataState.newName));
      }
    });
    return _formBloc;
  }


  @override
  ActionsOverviewScreenState get initialState => ActionsOverviewLoadSuccess((_appBloc.state as AppLoadSuccess).procedures);


  ActionsOverviewScreenBloc(this._appBloc);


  @override
  Stream<ActionsOverviewScreenState> mapEventToState(ActionsOverviewScreenEvent event) async*{
    if (event is ActionsOverviewProcedureAdded) {
      yield* _actionsOverviewProcedureAdded(event);
    }
  }


  Stream<ActionsOverviewScreenState> _actionsOverviewProcedureAdded(ActionsOverviewProcedureAdded event) async*{
    if (state is ActionsOverviewLoadSuccess) {
      var insertion = await SQLiteDbProvider.db.insertProcedure(event.newProcedureName);
      if (insertion.isFailure) {
        yield ActionsOverviewProcedureSaveFailure(insertion.lastMessage);

      } else {
        List<ProcedureImmutable> updatedList = List.from(
          (state as ActionsOverviewLoadSuccess).procedures
        )..insert(0, insertion.value);
        yield ActionsOverviewProcedureSaveSuccess(UnmodifiableListView(updatedList));
        _appBloc.add(AppProcedureAdded(insertion.value));
      }
    }
  }


  void dispose() {
    if (_formBloc != null) {
      _creationFormSubscription.cancel();
      _formBloc.close();
    }
    this.close();
  }
}