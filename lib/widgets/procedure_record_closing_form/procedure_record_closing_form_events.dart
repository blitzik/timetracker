abstract class ProcedureRecordClosingEvent {}


class ProcedureRecordClosed extends ProcedureRecordClosingEvent {
  final DateTime finish;
  final int quantity;

  ProcedureRecordClosed(this.finish, this.quantity);
}