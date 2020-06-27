import 'package:app/domain/procedure_immutable.dart';


abstract class AddProcedureRecordEvent {}


class AddProcedureRecordFormSent extends AddProcedureRecordEvent {
  final int lastRecordQuantity;
  final DateTime start;
  final ProcedureImmutable procedure;

  AddProcedureRecordFormSent(
    this.lastRecordQuantity,
    this.start,
    this.procedure
  );
}