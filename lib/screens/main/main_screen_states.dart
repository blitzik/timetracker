import 'package:app/domain/procedure_record_immutable.dart';
import 'dart:collection';


abstract class ProcedureRecordsState {}


class ProcedureRecordsLoadInProgress extends ProcedureRecordsState {}


class ProcedureRecordsLoadingFailure extends ProcedureRecordsState {
  final String message;

  ProcedureRecordsLoadingFailure(this.message);
}


class ProcedureRecordsLoadSuccess extends ProcedureRecordsState {
  final UnmodifiableListView<ProcedureRecordImmutable> records;

  double _workedHours;
  double get workedHours => _workedHours;

  ProcedureRecordImmutable get lastProcedureRecord => records.isEmpty ? null : records[0];


  ProcedureRecordsLoadSuccess(this.records) : assert (records != null) {
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

  ProcedureRecordAddedSuccess(this.addedRecord, UnmodifiableListView<ProcedureRecordImmutable> records) : super(records);
}


class ProcedureRecordDeletedSuccess extends ProcedureRecordsLoadSuccess {
  final ProcedureRecordImmutable deletedRecord;
  ProcedureRecordDeletedSuccess(this.deletedRecord, UnmodifiableListView<ProcedureRecordImmutable> records) : super(records);
}