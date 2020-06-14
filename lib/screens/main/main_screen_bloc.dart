import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/screens/main/main_screen_events.dart';
import 'package:app/screens/main/main_screen_states.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:collection';
import 'dart:async';


class MainScreenBloc extends Bloc<ProcedureRecordsEvents, ProcedureRecordsState> {

  MainScreenBloc();


  @override
  ProcedureRecordsState get initialState => ProcedureRecordsLoadInProgress();


  @override
  Stream<ProcedureRecordsState> mapEventToState(ProcedureRecordsEvents event) async*{
    if (event is ProcedureRecordsLoaded) {
      yield* _procedureRecordsLoadedToState(event);

    } else if (event is ProcedureRecordAdded) {
      yield* _procedureRecordAddedToState(event);

    } else if (event is LastProcedureRecordDeleted) {
      yield* _lastProcedureRecordDeletedToState(event);

    } else if (event is ProcedureRecordUpdated) {
      yield* _procedureRecordUpdatedToState(event);
    }
  }


  Stream<ProcedureRecordsState> _procedureRecordsLoadedToState(ProcedureRecordsLoaded event) async*{
    yield ProcedureRecordsLoadInProgress();
    var result = await _loadData(event.date);
    if (result.isSuccess) {
      yield ProcedureRecordsLoadSuccess(UnmodifiableListView(result.result));
    } else {
      yield ProcedureRecordsLoadingFailure(result.lastMessage);
    }
  }


  Stream<ProcedureRecordsState> _procedureRecordAddedToState(ProcedureRecordAdded event) async*{
    List<ProcedureRecordImmutable> updatedRecords = List.from((state as ProcedureRecordsLoadSuccess).records);
    if (updatedRecords.isNotEmpty) {
      updatedRecords.removeAt(0);
      updatedRecords.insert(0, event.formState.lastRecord);
    }
    updatedRecords.insert(0, event.formState.newRecord);

    yield ProcedureRecordAddedSuccess(event.formState.newRecord, UnmodifiableListView(updatedRecords));
  }


  Stream<ProcedureRecordsState> _lastProcedureRecordDeletedToState(LastProcedureRecordDeleted event) async*{
    if (state is ProcedureRecordsLoadSuccess) {
      var st = (state as ProcedureRecordsLoadSuccess);
      if (st.lastProcedureRecord != null) {
        var result = await SQLiteDbProvider.db.deleteProcedureRecord(st.lastProcedureRecord);
        if (result.isSuccess) {
          var deletedRecord;
          List<ProcedureRecordImmutable> updatedRecords = List.from(st.records);
          deletedRecord = updatedRecords.removeAt(0);
          yield ProcedureRecordDeletedSuccess(deletedRecord, UnmodifiableListView(updatedRecords));
        }
      }
    }
  }


  Stream<ProcedureRecordsState> _procedureRecordUpdatedToState(ProcedureRecordUpdated event) async*{
    if (state is ProcedureRecordsLoadSuccess) {
      List<ProcedureRecordImmutable> updatedRecords = List.from((state as ProcedureRecordsLoadSuccess).records);
      updatedRecords.removeAt(0);
      updatedRecords.insert(0, event.record);
      yield ProcedureRecordsLoadSuccess(UnmodifiableListView(updatedRecords));
    }
  }


  Future<ResultObject<List<ProcedureRecordImmutable>>> _loadData(DateTime date) {
    return SQLiteDbProvider.db.findAllProcedureRecords(date.year, date.month, date.day);
  }


  void dispose() {
    this.close();
  }
}