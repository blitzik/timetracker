import 'package:app/domain/procedure_immutable.dart';


abstract class ProcedureRecordEditFormEvent {}


class EditFormInitialized extends ProcedureRecordEditFormEvent {}


class EditFormStateChanged extends ProcedureRecordEditFormEvent {
  final ProcedureImmutable selectedProcedure;
  final int quantity;

  EditFormStateChanged(this.selectedProcedure, this.quantity);
}


class EditFormSent extends ProcedureRecordEditFormEvent {
  final int quantity;
  final ProcedureImmutable procedure;

  EditFormSent(this.quantity, this.procedure);
}