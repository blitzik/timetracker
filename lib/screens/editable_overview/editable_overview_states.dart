import 'package:app/domain/procedure_record_immutable.dart';
import 'dart:collection';


abstract class ProcedureRecordsState {
  final DateTime date;

  ProcedureRecordsState(this.date);
}


class ProcedureRecordsLoadInProgress extends ProcedureRecordsState {
  ProcedureRecordsLoadInProgress(DateTime date) : super(date);
}


class ProcedureRecordsLoadingFailure extends ProcedureRecordsState {
  final String message;

  ProcedureRecordsLoadingFailure(DateTime date, this.message) : super(date);
}


class ProcedureRecordsLoadSuccess extends ProcedureRecordsState {
  final UnmodifiableListView<ProcedureRecordImmutable> records;

  double _workedHours;
  double get workedHours => _workedHours;

  ProcedureRecordImmutable get lastProcedureRecord => records.isEmpty ? null : records[0];


  ProcedureRecordsLoadSuccess(DateTime date, this.records) : assert (records != null), super(date) {
    _workedHours = _calculateWorkedHours(records);
  }


  double _calculateWorkedHours(List<ProcedureRecordImmutable> records) {
    double workedHours = 0;
    records.forEach((record) {
      if (record.timeSpent == null || record.isBreak) return;
      workedHours += record.timeSpent;
    });
    return workedHours;
  }
}


class ProcedureRecordAddedSuccess extends ProcedureRecordsLoadSuccess {
  final ProcedureRecordImmutable addedRecord;

  ProcedureRecordAddedSuccess(DateTime date, this.addedRecord, UnmodifiableListView<ProcedureRecordImmutable> records) : super(date, records);
}


class ProcedureRecordDeletedSuccess extends ProcedureRecordsLoadSuccess {
  final ProcedureRecordImmutable deletedRecord;
  ProcedureRecordDeletedSuccess(DateTime date, this.deletedRecord, UnmodifiableListView<ProcedureRecordImmutable> records) : super(date, records);
}