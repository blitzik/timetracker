import 'package:app/domain/procedure.dart';

abstract class ProcedureRecordItemEvent {}


class ProcedureRecordOpened extends ProcedureRecordItemEvent {}


class ProcedureRecordClosed extends ProcedureRecordItemEvent {
  final DateTime finish;
  final int quantity;

  ProcedureRecordClosed(this.finish, this.quantity);
}


class ProcedureRecordUpdated extends ProcedureRecordItemEvent {
  final int quantity;
  final Procedure procedure;

  ProcedureRecordUpdated(this.quantity, this.procedure);
}