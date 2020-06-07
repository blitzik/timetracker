import 'package:app/domain/procedure_record.dart';
import 'dart:collection';


abstract class ProcedureRecordsState {}


class ProcedureRecordsLoadInProgress extends ProcedureRecordsState {}


class ProcedureRecordsLoadingFailure extends ProcedureRecordsState {
  final String message;

  ProcedureRecordsLoadingFailure(this.message);
}


class ProcedureRecordsLoadSuccess extends ProcedureRecordsState {
  final UnmodifiableListView<ProcedureRecord> records;

  double _workedHours;
  double get workedHours => _workedHours;

  ProcedureRecord get lastProcedureRecord => records.isEmpty ? null : records[0];


  ProcedureRecordsLoadSuccess(this.records) : assert (records != null) {
    _workedHours = _calculateWorkedHours(records);
  }


  double _calculateWorkedHours(List<ProcedureRecord> records) {
    double workedHours = 0;
    records.forEach((record) {
      if (record.timeSpent == null || record.isBreak) return;
      workedHours += record.timeSpent;
    });
    return workedHours;
  }
}


class ProcedureRecordAddedSuccess extends ProcedureRecordsLoadSuccess {
  final ProcedureRecord addedRecord;

  ProcedureRecordAddedSuccess(this.addedRecord, UnmodifiableListView<ProcedureRecord> records) : super(records);
}


class ProcedureRecordDeletedSuccess extends ProcedureRecordsLoadSuccess {
  final ProcedureRecord deletedRecord;
  ProcedureRecordDeletedSuccess(this.deletedRecord, UnmodifiableListView<ProcedureRecord> records) : super(records);
}