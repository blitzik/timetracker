import 'package:app/domain/procedure_immutable.dart';


abstract class ProcedureRecordItemEvent {}


class ProcedureRecordOpened extends ProcedureRecordItemEvent {}


class ProcedureRecordClosed extends ProcedureRecordItemEvent {
  final DateTime finish;
  final int quantity;

  ProcedureRecordClosed(this.finish, this.quantity);
}


class ProcedureRecordUpdated extends ProcedureRecordItemEvent {
  final int quantity;
  final ProcedureImmutable procedure;

  ProcedureRecordUpdated(this.quantity, this.procedure);
}