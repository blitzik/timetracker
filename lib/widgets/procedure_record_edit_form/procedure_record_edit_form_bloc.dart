import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_events.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_states.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProcedureRecordEditFormBloc extends Bloc<ProcedureRecordEditFormEvent, ProcedureRecordEditFormState> {
  final ProcedureRecord _record;


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
}