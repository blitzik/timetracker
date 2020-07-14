import 'package:app/domain/procedure_immutable.dart';


abstract class ProcedureRecordCreationFormEvent {}


class ProcedureRecordCreated extends ProcedureRecordCreationFormEvent {
  final ProcedureImmutable procedure;
  final DateTime start;

  ProcedureRecordCreated(this.procedure, this.start);
}