import 'package:app/screens/add_procedure_record/add_procedure_record_screen_states.dart';
import 'package:app/domain/procedure_record_immutable.dart';


abstract class ProcedureRecordsEvents {
  const ProcedureRecordsEvents();
}


class ProcedureRecordsLoaded extends ProcedureRecordsEvents {
  const ProcedureRecordsLoaded();
}


class ProcedureRecordAdded extends ProcedureRecordsEvents {
  final AddProcedureRecordFormProcessingSucceeded formState;

  const ProcedureRecordAdded(this.formState);
}


class LastProcedureRecordDeleted extends ProcedureRecordsEvents {}


class ProcedureRecordUpdated extends ProcedureRecordsEvents {
  final ProcedureRecordImmutable record;

  ProcedureRecordUpdated(this.record);
}