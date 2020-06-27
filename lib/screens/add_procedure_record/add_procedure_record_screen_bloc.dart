import 'package:app/screens/add_procedure_record/add_procedure_record_screen_events.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen_states.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:collection';


class AddProcedureRecordScreenBloc extends Bloc<AddProcedureRecordEvent, AddProcedureRecordState> {
  ProcedureRecordImmutable _lastRecord;
  final UnmodifiableListView<ProcedureImmutable> _procedures;


  @override
  AddProcedureRecordState get initialState => AddProcedureRecordFormState(
      _lastRecord,
      _procedures,
      null, null, null
  );


  @override
  Stream<AddProcedureRecordState> mapEventToState(AddProcedureRecordEvent event) async*{
    if (event is AddProcedureRecordFormSent) {
      yield* _addProcedureRecordFormSentToState(event);
    }
  }


  AddProcedureRecordScreenBloc(this._lastRecord, this._procedures);



  Stream<AddProcedureRecordState> _addProcedureRecordFormSentToState(AddProcedureRecordFormSent event) async*{
    var insertion = await SQLiteDbProvider.db.startProcedureRecord(_lastRecord, event.lastRecordQuantity, event.procedure, event.start);
    if (insertion.isSuccess) {
      _lastRecord = insertion.result['lastRecord'];
      yield AddProcedureRecordFormProcessingSucceeded(insertion.result['lastRecord'], insertion.result['newRecord']);
    } else {
      yield AddProcedureRecordFormProcessingFailed(insertion.result['lastRecord'], insertion.lastMessage);
    }
  }


  void dispose() {
    this.close();
  }
}