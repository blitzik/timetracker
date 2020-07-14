import 'package:app/widgets/procedure_item_widget/procedure_items_widget_events.dart';
import 'package:app/widgets/procedure_item_widget/procedure_item_widget_states.dart';
import 'package:app/widgets/procedure_form/procedure_form_states.dart';
import 'package:app/widgets/procedure_form/procedure_form_bloc.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/app_bloc.dart';
import 'dart:async';


class ProcedureItemWidgetBloc extends Bloc<ProcedureItemWidgetEvent, ProcedureItemState> {
  final ProcedureImmutable _procedure;
  final AppBloc _appBloc;


  ProcedureFormBloc _formBloc;
  StreamSubscription<ProcedureFormState> _formSubscription;
  ProcedureFormBloc get formBloc {
    if (_formBloc != null) {
      _formBloc.close();
      _formSubscription.cancel();
    }

    _formBloc = ProcedureFormBloc(state.procedure);
    _formSubscription = _formBloc.listen((onDataState) {
      if (onDataState is ProcedureFormProcessingSuccess) {
        this.add(ProcedureUpdated(onDataState.newName));
      }
    });

    return _formBloc;
  }


  @override
  ProcedureItemState get initialState => ProcedureItemDefaultState(_procedure);


  ProcedureItemWidgetBloc(this._procedure, this._appBloc);



  @override
  Stream<ProcedureItemState> mapEventToState(ProcedureItemWidgetEvent event) async*{
    if (event is ProcedureUpdated) {
      yield* _procedureUpdatedToState(event);
    }
  }


  Stream<ProcedureItemState> _procedureUpdatedToState(ProcedureUpdated event) async*{
    var update = await SQLiteDbProvider.db.updateProcedure(state.procedure, event.newName);
    if (update.isSuccess) {
      yield ProcedureItemUpdateSuccess(update.value);
      _appBloc.add(AppProcedureUpdated(update.value));

    } else {
      yield ProcedureItemUpdateFailure(state.procedure, update.lastMessage);
    }
  }


  void dispose() {
    if (_formBloc != null) {
      _formSubscription.cancel();
      _formBloc.close();
    }
    this.close();
  }
}