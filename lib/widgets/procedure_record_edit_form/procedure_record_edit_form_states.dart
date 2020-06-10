import 'package:app/domain/ProcedureRecordImmutable.dart';
import 'package:app/domain/procedure.dart';
import 'dart:collection';


abstract class ProcedureRecordEditFormState {
  final ProcedureRecordImmutable record;

  ProcedureRecordEditFormState(this.record);
}


class EditFormProceduresLoadInProgress extends ProcedureRecordEditFormState {
  EditFormProceduresLoadInProgress(ProcedureRecordImmutable record) : super(record);
}


class EditFormState extends ProcedureRecordEditFormState {
  Map<String, Procedure> _procedures = Map();
  UnmodifiableMapView<String, Procedure> get procedures => UnmodifiableMapView(_procedures);


  final Procedure selectedProcedure;
  final int quantity;


  EditFormState(
    List<Procedure> procedures,
    ProcedureRecordImmutable record,
    this.selectedProcedure,
    this.quantity
  ) : super(record) {
    Map<String, Procedure> result = Map();
    procedures.forEach((procedure) {
      result[procedure.name] = procedure;
    });
    _procedures = result;
  }
}


class EditFormProceduresLoadFailure extends ProcedureRecordEditFormState {
  final String errorMessage;

  EditFormProceduresLoadFailure(
    ProcedureRecordImmutable record, this.errorMessage
  ) : super(record);
}


class EditFormProcessingSuccess extends EditFormState {
  EditFormProcessingSuccess(
    List<Procedure> procedures,
    ProcedureRecordImmutable record,
    Procedure selectedProcedure,
    int quantity
  ) : super(procedures, record, selectedProcedure, quantity);
}