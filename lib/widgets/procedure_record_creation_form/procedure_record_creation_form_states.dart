import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'dart:collection';


abstract class ProcedureRecordCreationFormState {}


class ProcedureRecordCreationFormInitial extends ProcedureRecordCreationFormState {
  ProcedureRecordImmutable lastRecord;

  Map<String, ProcedureImmutable> _procedures = Map();
  UnmodifiableMapView<String, ProcedureImmutable> get procedures => UnmodifiableMapView(_procedures);


  ProcedureRecordCreationFormInitial(UnmodifiableListView<ProcedureImmutable> procedures, this.lastRecord) {
    Map<String, ProcedureImmutable> result = Map();
    procedures.forEach((procedure) {
      result[procedure.name] = procedure;
    });

    _procedures = result;
  }
}


class ProcedureRecordCreationInProgress extends ProcedureRecordCreationFormState {}


class ProcedureRecordCreationSuccess extends ProcedureRecordCreationFormState {
  final ProcedureRecordImmutable newRecord;

  ProcedureRecordCreationSuccess(this.newRecord);
}


class ProcedureRecordCreationFailure extends ProcedureRecordCreationFormState {
  final String errorMessage;

  ProcedureRecordCreationFailure(this.errorMessage);
}