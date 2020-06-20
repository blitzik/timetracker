import 'package:app/screens/editable_overview/editable_overview_states.dart';
import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'dart:collection';


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
  final ProcedureRecordImmutable newRecord;

  AddProcedureRecordFormProcessingSucceeded(ProcedureRecordImmutable lastRecord, this.newRecord) : super(lastRecord);
}


class AddProcedureRecordFormProcessingFailed extends AddProcedureRecordState {
  final String message;
  AddProcedureRecordFormProcessingFailed(ProcedureRecordImmutable lastRecord, this.message) : super(lastRecord);
}


class AddProcedureRecordFormState extends AddProcedureRecordState {
  Map<String, ProcedureImmutable> _procedures = Map();
  UnmodifiableMapView<String, ProcedureImmutable> get procedures => UnmodifiableMapView(_procedures);

  final String selectedProcedure;
  final int lastProcedureQuantity;
  final DateTime newActionStart;


  AddProcedureRecordFormState(
    ProcedureRecordImmutable lastRecord,
    List<ProcedureImmutable> procedures,
    this.selectedProcedure,
    this.lastProcedureQuantity,
    this.newActionStart
  ) : super(lastRecord) {
    Map<String, ProcedureImmutable> result = Map();
    procedures.forEach((procedure) {
      result[procedure.name] = procedure;
    });

    _procedures = result;
  }
}