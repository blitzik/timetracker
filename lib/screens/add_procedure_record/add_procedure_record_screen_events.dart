import 'package:app/domain/procedure.dart';

abstract class AddProcedureRecordEvent {}


class AddProcedureRecordFormProceduresLoaded extends AddProcedureRecordEvent {}


class AddProcedureRecordFormSent extends AddProcedureRecordEvent {
  final int lastRecordQuantity;
  final DateTime start;
  final Procedure procedure;

  AddProcedureRecordFormSent(
    this.lastRecordQuantity,
    this.start,
    this.procedure
  );
}