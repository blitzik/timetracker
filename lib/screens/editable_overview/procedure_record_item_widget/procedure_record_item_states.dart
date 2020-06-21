import 'package:app/domain/procedure_record_immutable.dart';


abstract class ProcedureRecordItemState {
  final ProcedureRecordImmutable record;

  ProcedureRecordItemState(this.record);
}


class ProcedureRecordItemDefaultState extends ProcedureRecordItemState {
  final bool isLast;

  ProcedureRecordItemDefaultState(
    ProcedureRecordImmutable record,
    this.isLast
  ) : assert(record != null),
      super(record);
}


