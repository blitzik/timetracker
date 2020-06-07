abstract class ProcedureRecordItemEvent {}


class ProcedureRecordOpened extends ProcedureRecordItemEvent {}


class ProcedureRecordClosed extends ProcedureRecordItemEvent {
  final DateTime finish;
  final int quantity;

  ProcedureRecordClosed(this.finish, this.quantity);
}