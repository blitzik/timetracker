import 'package:app/screens/main/main_screen_events.dart';
import 'package:app/screens/main/main_screen_states.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/storage/sqlite_db_provider.dart';
import 'package:app/domain/procedure_record.dart';
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
    final List<ProcedureRecord> updatedRecords = List.from((state as ProcedureRecordsLoadSuccess).records)..insert(0, event.record);
    yield RecordAddedSuccess(event.record, UnmodifiableListView(updatedRecords));
  }


  Future<ResultObject<List<ProcedureRecord>>> _loadData(DateTime date) {
    return SQLiteDbProvider.db.findAllProcedureRecords(date.year, date.month, date.day);
  }


  /*double _calculateWorkedHours(List<ProcedureRecord> records) {
    double workedHours = 0;
    records.forEach((f) {
      if (f.timeSpent == null || f.procedure.id == 1) return;
      workedHours += f.timeSpent;
    });
    return workedHours;
  }*/


  /*void deleteLastRecord() async{
    if (_records != null && _records.isNotEmpty) {
      SQLiteDbProvider.db.deleteProcedureRecord(_records[0]);
    }
    _records.removeAt(0);
  }*/


  /*void refreshWorkedHours() {
    _workedHoursController.add(_calculateWorkedHours(_records));
  }*/


  void dispose() {
    this.close();
  }
}