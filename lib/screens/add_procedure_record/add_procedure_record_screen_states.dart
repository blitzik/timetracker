import 'package:app/domain/ProcedureRecordImmutable.dart';
import 'package:app/domain/procedure.dart';
import 'dart:collection';


abstract class AddProcedureRecordState {}


class AddProcedureRecordStateInitial extends AddProcedureRecordState {
  AddProcedureRecordStateInitial();
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
  ) {
    Map<String, Procedure> result = Map();
    procedures.forEach((procedure) {
      result[procedure.name] = procedure;
    });

    _procedures = result;
  }
}