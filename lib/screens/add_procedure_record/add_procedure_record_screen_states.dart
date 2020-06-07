import 'package:app/domain/ProcedureRecordImmutable.dart';
import 'package:app/domain/procedure.dart';
import 'dart:collection';

import 'package:app/domain/procedure_record.dart';


abstract class AddProcedureRecordState {
  final ProcedureRecordImmutable lastRecord;

  AddProcedureRecordState(this.lastRecord);
}


class AddProcedureRecordLoadInProgress extends AddProcedureRecordState {
  AddProcedureRecordLoadInProgress(ProcedureRecordImmutable lastRecord) : super(lastRecord);
}


class AddProcedureRecordLoadFailed extends AddProcedureRecordState {
  final String message;

  AddProcedureRecordLoadFailed(ProcedureRecordImmutable lastRecord, this.message) : super(lastRecord);
}


class AddProcedureRecordFormProcessingSucceeded extends AddProcedureRecordState {
  final ProcedureRecord newRecord;
  AddProcedureRecordFormProcessingSucceeded(ProcedureRecordImmutable lastRecord, this.newRecord) : super(lastRecord);
}


class AddProcedureRecordFormProcessingFailed extends AddProcedureRecordState {
  final String message;
  AddProcedureRecordFormProcessingFailed(ProcedureRecordImmutable lastRecord, this.message) : super(lastRecord);
}


class AddProcedureRecordFormState extends AddProcedureRecordState {
  final ProcedureRecordImmutable lastRecord;

  Map<String, Procedure> _procedures = Map();
  UnmodifiableMapView<String, Procedure> get procedures => UnmodifiableMapView(_procedures);

  final String selectedProcedure;
  final int lastProcedureQuantity;
  final DateTime newActionStart;


  AddProcedureRecordFormState(
    this.lastRecord,
    List<Procedure> procedures,
    this.selectedProcedure,
    this.lastProcedureQuantity,
    this.newActionStart
  ) : super(lastRecord) {
    Map<String, Procedure> result = Map();
    procedures.forEach((procedure) {
      result[procedure.name] = procedure;
    });

    _procedures = result;
  }
}