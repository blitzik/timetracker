import 'package:app/domain/procedure.dart';


abstract class ProcedureRecordEditFormEvent {}


class EditFormInitialized extends ProcedureRecordEditFormEvent {}


class EditFormStateChanged extends ProcedureRecordEditFormEvent {
  final Procedure selectedProcedure;
  final int quantity;

  EditFormStateChanged(this.selectedProcedure, this.quantity);
}


class EditFormSent extends ProcedureRecordEditFormEvent {
  final int quantity;
  final Procedure procedure;

  EditFormSent(this.quantity, this.procedure);
}