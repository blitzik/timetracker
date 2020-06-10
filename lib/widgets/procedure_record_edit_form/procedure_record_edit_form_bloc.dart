import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_events.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_states.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/domain/procedure.dart';
import 'dart:collection';


class ProcedureRecordEditFormBloc extends Bloc<ProcedureRecordEditFormEvent, ProcedureRecordEditFormState> {
  final ProcedureRecord _record;


  Map<String, Procedure> _procedures = Map();
  UnmodifiableMapView<String, Procedure> get procedures => UnmodifiableMapView(_procedures);


  @override
  ProcedureRecordEditFormState get initialState => EditFormProceduresLoadInProgress(_record.toImmutable());


  ProcedureRecordEditFormBloc(this._record);


  @override
  Stream<ProcedureRecordEditFormState> mapEventToState(ProcedureRecordEditFormEvent event) async*{
    if (event is EditFormInitialized) {
      yield* _editFormInitializedToState(event);
    } else if (event is EditFormSent) {
      yield* _editFormSentToState(event);
    }
  }


  Stream<ProcedureRecordEditFormState> _editFormInitializedToState(EditFormInitialized event) async*{
    yield EditFormProceduresLoadInProgress(state.record);
    var proceduresResult = await SQLiteDbProvider.db.findAllProcedures();
    if (proceduresResult.isSuccess) {
      yield EditFormState(proceduresResult.result, state.record, null, null);
    } else {
      yield EditFormProceduresLoadFailure(state.record, proceduresResult.lastMessage);
    }
  }


  Stream<ProcedureRecordEditFormState> _editFormSentToState(EditFormSent event) async*{
    if (state is EditFormState) {
      yield EditFormProcessingSuccess(
        List.from((state as EditFormState).procedures.values),
        state.record,
        event.procedure,
        event.quantity
      );
    }
  }


  void dispose() {
    this.close();
  }


  /*Future<ResultObject<void>> save() async{
    if (quantity == _record.quantity && selectedProcedure == _record.procedure.name) {
      return Future.value(ResultObject<void>());
    }

    var oldProcedure = _record.procedure;
    var oldQuantity = _record.quantity;

    _record.procedure = _procedures[selectedProcedure];
    _record.quantity = quantity;

    var result = await SQLiteDbProvider.db.updateProcedureRecord(_record);
    if (result.isSuccess) {
      _onSavedRecord?.call();
    } else {
      _record.procedure = oldProcedure;
      _record.quantity = oldQuantity;
    }
    return Future.value(result);
  }*/
}