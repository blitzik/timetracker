import 'package:app/domain/procedure_record_immutable.dart';


abstract class ProcedureRecordClosingFormState {}


class ProcedureRecordClosingInProgress extends ProcedureRecordClosingFormState {}


class ProcedureRecordClosingFormDefault extends ProcedureRecordClosingFormState {
  final ProcedureRecordImmutable record;
  final bool isFirstRecordOfDay;

  ProcedureRecordClosingFormDefault(
    this.record,
    this.isFirstRecordOfDay) :
      assert(record != null),
      assert(isFirstRecordOfDay != null);
}


class ProcedureRecordClosingSuccess extends ProcedureRecordClosingFormDefault {
  ProcedureRecordClosingSuccess(
    ProcedureRecordImmutable record,
    bool isMidnightForToday) :
      assert(record != null),
      assert(isMidnightForToday != null),
      super(record, isMidnightForToday);
}


class ProcedureRecordClosingFailure extends ProcedureRecordClosingFormState {
  final String errorMessage;

  ProcedureRecordClosingFailure(this.errorMessage);
}