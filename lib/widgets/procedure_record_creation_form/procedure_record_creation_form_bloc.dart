import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form_events.dart';
import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form_states.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:collection';


class ProcedureRecordCreationFormBloc extends Bloc<ProcedureRecordCreationFormEvent, ProcedureRecordCreationFormState> {

  final UnmodifiableListView<ProcedureImmutable> _procedures;
  final ProcedureRecordImmutable _lastRecord;


  @override
  ProcedureRecordCreationFormState get initialState => ProcedureRecordCreationFormInitial(_procedures, _lastRecord);


  ProcedureRecordCreationFormBloc(this._procedures, this._lastRecord);


  @override
  Stream<ProcedureRecordCreationFormState> mapEventToState(ProcedureRecordCreationFormEvent event) async*{

  }


  void dispose() {
    this.close();
  }

}