import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form_events.dart';
import 'package:app/widgets/procedure_record_creation_form/procedure_record_creation_form_states.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:collection';


class ProcedureRecordCreationFormBloc extends Bloc<ProcedureRecordCreationFormEvent, ProcedureRecordCreationFormState> {


  ProcedureRecordCreationFormBloc(
    UnmodifiableListView<ProcedureImmutable> procedures,
    ProcedureRecordImmutable lastRecord
  ) : super(ProcedureRecordCreationFormInitial(procedures, lastRecord));


  @override
  Stream<ProcedureRecordCreationFormState> mapEventToState(ProcedureRecordCreationFormEvent event) async*{
    if (event is ProcedureRecordCreated) {
      yield* _procedureRecordCreatedToState(event);
    }
  }


  Stream<ProcedureRecordCreationFormState> _procedureRecordCreatedToState(ProcedureRecordCreated event) async*{
    yield ProcedureRecordCreationInProgress();
    ResultObject<ProcedureRecordImmutable> insertionResult = await SQLiteDbProvider.db.startProcedureRecord(event.procedure, event.start);
    if (insertionResult.isSuccess) {
      yield ProcedureRecordCreationSuccess(insertionResult.value);
    } else {
      yield ProcedureRecordCreationFailure(insertionResult.lastMessage);
    }
  }


  void dispose() {
    this.close();
  }

}