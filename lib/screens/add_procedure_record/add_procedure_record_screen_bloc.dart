import 'package:app/screens/add_procedure_record/add_procedure_record_screen_events.dart';
import 'package:app/screens/add_procedure_record/add_procedure_record_screen_states.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AddProcedureRecordScreenBloc extends Bloc<AddProcedureRecordEvent, AddProcedureRecordState> {
  final ProcedureRecordImmutable _lastRecord;


  @override
  AddProcedureRecordState get initialState => AddProcedureRecordLoadInProgress(_lastRecord);


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
    yield AddProcedureRecordLoadInProgress(state.lastRecord);
    var proceduresLoading = await SQLiteDbProvider.db.findAllProcedures();
    if (proceduresLoading.isSuccess) {
      yield AddProcedureRecordFormState(
        state.lastRecord,
          proceduresLoading.result,
        null,
        null,
        null
      );

    } else {
      yield AddProcedureRecordLoadFailed(_lastRecord, proceduresLoading.lastMessage);
    }
  }


  Stream<AddProcedureRecordState> _addProcedureRecordFormSentToState(AddProcedureRecordFormSent event) async*{
    var insertion = await SQLiteDbProvider.db.startProcedureRecord(_lastRecord, event.lastRecordQuantity, event.procedure, event.start);
    if (insertion.isSuccess) {
      yield AddProcedureRecordFormProcessingSucceeded(insertion.result['lastRecord'], insertion.result['newRecord']);
    } else {
      yield AddProcedureRecordFormProcessingFailed(_lastRecord, insertion.lastMessage);
    }
  }


  void dispose() {
    this.close();
  }
}