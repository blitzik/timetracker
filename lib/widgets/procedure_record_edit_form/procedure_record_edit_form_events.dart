import 'package:app/domain/procedure.dart';


abstract class ProcedureRecordEditFormEvent {}


class EditFormInitialized extends ProcedureRecordEditFormEvent {}


class EditFormSent extends ProcedureRecordEditFormEvent {
  final int quantity;
  final Procedure procedure;

  EditFormSent(this.quantity, this.procedure);
}