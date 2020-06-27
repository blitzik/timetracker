import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_events.dart';
import 'package:app/widgets/procedure_record_edit_form/procedure_record_edit_form_states.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:collection';


class ProcedureRecordEditFormBloc extends Bloc<ProcedureRecordEditFormEvent, ProcedureRecordEditFormState> {
  final ProcedureRecordImmutable _record;
  final UnmodifiableListView<ProcedureImmutable> _procedures;


  @override
  ProcedureRecordEditFormState get initialState => EditFormState(_procedures, _record, null, null);


  ProcedureRecordEditFormBloc(this._record, this._procedures);


  @override
  Stream<ProcedureRecordEditFormState> mapEventToState(ProcedureRecordEditFormEvent event) async*{
    if (event is EditFormSent) {
      yield* _editFormSentToState(event);
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