import 'package:app/domain/procedure_immutable.dart';

abstract class ProcedureFormState {
  final ProcedureImmutable procedure;

  ProcedureFormState(this.procedure);
}


class ProcedureFormDefault extends ProcedureFormState {
  ProcedureFormDefault(ProcedureImmutable procedure) : super(procedure);
}


class ProcedureFormProcessingSuccess extends ProcedureFormState {
  final String newName;

  ProcedureFormProcessingSuccess(ProcedureImmutable procedure, this.newName) : super(procedure);
}