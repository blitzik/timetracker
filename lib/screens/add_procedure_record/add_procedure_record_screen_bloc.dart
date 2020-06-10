import 'package:app/screens/add_procedure_record/add_procedure_record_screen_events.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen_states.dart';
import 'package:app/domain/ProcedureRecordImmutable.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AddProcedureRecordScreenBloc extends Bloc<AddProcedureRecordEvent, AddProcedureRecordState> {
  final ProcedureRecord _lastRecord;


  @override
  AddProcedureRecordState get initialState => AddProcedureRecordLoadInProgress(
    _getImmutableRecord(_lastRecord)
  );


  @override
  Stream<AddProcedureRecordState> mapEventToState(AddProcedureRecordEvent event) async*{
    if (event is AddProcedureRecordFormProceduresLoaded) {
      yield* _addProcedureRecordFormProceduresLoadedToState(event);

    } else if (event is AddProcedureRecordFormSent) {
      yield* _addProcedureRecordFormSentToState(event);
    }
  }


  AddProcedureRecordScreenBloc(this._lastRecord);


  Stream<AddProcedureRecordState> _addProcedureRecordFormProceduresLoadedToState(AddProcedureRecordFormProceduresLoaded event) async*{
    yield AddProcedureRecordLoadInProgress(_getImmutableRecord(_lastRecord));
    var proceduresResult = await SQLiteDbProvider.db.findAllProcedures();
    if (proceduresResult.isSuccess) {
      yield AddProcedureRecordFormState(
        _getImmutableRecord(_lastRecord),
        proceduresResult.result,
        null,
        null,
        null
      );

    } else {
      yield AddProcedureRecordLoadFailed(_getImmutableRecord(_lastRecord), proceduresResult.lastMessage);
    }
  }


  Stream<AddProcedureRecordState> _addProcedureRecordFormSentToState(AddProcedureRecordFormSent event) async*{
    var result = await SQLiteDbProvider.db.startProcedureRecord(_lastRecord,event.lastRecordQuantity, event.procedure, event.start);
    if (result.isSuccess) {
      yield AddProcedureRecordFormProcessingSucceeded(_getImmutableRecord(_lastRecord), result.result);
    } else {
      yield AddProcedureRecordFormProcessingFailed(_getImmutableRecord(_lastRecord), result.lastMessage);
    }
  }


  ProcedureRecordImmutable _getImmutableRecord(ProcedureRecord record) {
    if (record == null) {
      return null;
    }
    return record.toImmutable();
  }


  void dispose() {
    this.close();
  }
}