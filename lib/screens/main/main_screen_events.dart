import 'package:app/domain/procedure_record.dart';

abstract class ProcedureRecordsEvents {
  const ProcedureRecordsEvents();
}


class ProcedureRecordsLoaded extends ProcedureRecordsEvents {
  final DateTime date;

  const ProcedureRecordsLoaded(this.date);
}


class ProcedureRecordAdded extends ProcedureRecordsEvents {
  final ProcedureRecord record;

  const ProcedureRecordAdded(this.record);
}