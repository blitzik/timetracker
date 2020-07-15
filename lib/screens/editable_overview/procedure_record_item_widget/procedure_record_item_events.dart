import 'package:app/domain/procedure_immutable.dart';
import 'package:app/domain/procedure_record_immutable.dart';


abstract class ProcedureRecordItemEvent {}


class ProcedureRecordOpened extends ProcedureRecordItemEvent {}


class ProcedureRecordClosed extends ProcedureRecordItemEvent {
  final ProcedureRecordImmutable record;

  ProcedureRecordClosed(this.record);
}


class ProcedureRecordUpdated extends ProcedureRecordItemEvent {
  final int quantity;
  final ProcedureImmutable procedure;

  ProcedureRecordUpdated(this.quantity, this.procedure);
}