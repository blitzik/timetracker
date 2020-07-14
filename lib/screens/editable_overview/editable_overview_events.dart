import 'package:app/domain/procedure_record_immutable.dart';


abstract class ProcedureRecordsEvents {
  const ProcedureRecordsEvents();
}


class ProcedureRecordsLoaded extends ProcedureRecordsEvents {
  const ProcedureRecordsLoaded();
}


class ProcedureRecordAdded extends ProcedureRecordsEvents {
  final ProcedureRecordImmutable newRecord;

  const ProcedureRecordAdded(this.newRecord);
}


class LastProcedureRecordDeleted extends ProcedureRecordsEvents {}


class ProcedureRecordUpdated extends ProcedureRecordsEvents {
  final ProcedureRecordImmutable record;

  ProcedureRecordUpdated(this.record);
}