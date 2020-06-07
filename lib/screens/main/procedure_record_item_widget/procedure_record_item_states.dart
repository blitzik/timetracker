import 'package:app/domain/ProcedureRecordImmutable.dart';


abstract class ProcedureRecordItemState {}


class ProcedureRecordItemLoaded extends ProcedureRecordItemState {
  final ProcedureRecordImmutable record;
  final bool isLast;

  ProcedureRecordItemLoaded(this.record, this.isLast) : assert(record != null);
}