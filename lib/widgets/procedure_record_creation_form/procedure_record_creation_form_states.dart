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


