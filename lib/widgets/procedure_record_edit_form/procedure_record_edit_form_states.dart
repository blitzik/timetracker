import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'dart:collection';


abstract class ProcedureRecordEditFormState {
  final ProcedureRecordImmutable record;

  ProcedureRecordEditFormState(this.record);
}


class EditFormProceduresLoadInProgress extends ProcedureRecordEditFormState {
  EditFormProceduresLoadInProgress(ProcedureRecordImmutable record) : super(record);
}


class EditFormState extends ProcedureRecordEditFormState {
  Map<String, ProcedureImmutable> _procedures = Map();
  UnmodifiableMapView<String, ProcedureImmutable> get procedures => UnmodifiableMapView(_procedures);


  final ProcedureImmutable selectedProcedure;
  final int quantity;


  EditFormState(
    List<ProcedureImmutable> procedures,
    ProcedureRecordImmutable record,
    this.selectedProcedure,
    this.quantity
  ) : super(record) {
    Map<String, ProcedureImmutable> result = Map();
    procedures.forEach((procedure) {
      result[procedure.name] = procedure;
    });
    _procedures = result;
  }


  EditFormState copyWith({
    ProcedureImmutable selectedProcedure,
    int quantity
  }) {
    return EditFormState(
      List.from(_procedures.values),
      record,
      selectedProcedure ?? this.selectedProcedure,
      quantity ?? this.quantity
    );
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
    List<ProcedureImmutable> procedures,
    ProcedureRecordImmutable record,
    ProcedureImmutable selectedProcedure,
    int quantity
  ) : super(procedures, record, selectedProcedure, quantity);
}